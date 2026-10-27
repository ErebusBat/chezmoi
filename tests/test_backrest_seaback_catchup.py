import datetime as dt
import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / 'home/private_dot_restic/private_executable_backrest-seaback-catchup'
loader = importlib.machinery.SourceFileLoader('catchup', str(SCRIPT))
spec = importlib.util.spec_from_loader('catchup', loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)


def backup(status, start, end=0, **extra):
    return dict(status=status, unixTimeStartMs=start*1000, unixTimeEndMs=end*1000,
                operationBackup={}, **extra)


class CatchupTests(unittest.TestCase):
    def test_daily_before_and_after_slot(self):
        s = {'cron': '35 17 * * *', 'clock': 'CLOCK_LOCAL'}
        now = dt.datetime(2026, 10, 27, 12).timestamp()
        self.assertEqual(m.latest_slot(s, now), dt.datetime(2026, 10, 26, 17, 35).timestamp())
        self.assertEqual(m.latest_slot(s, now+7*3600), dt.datetime(2026, 10, 27, 17, 35).timestamp())

    def test_weekly_sunday(self):
        s = {'cron': '35 18 * * 0', 'clock': 'CLOCK_LOCAL'}
        self.assertEqual(m.latest_slot(s, dt.datetime(2026, 10, 27, 12).timestamp()),
                         dt.datetime(2026, 10, 25, 18, 35).timestamp())

    def test_schedule_drift_fails_closed(self):
        for cron in ['*/15 * * * *', '35 * * * *', '99 17 * * *']:
            with self.assertRaises(ValueError):
                m.latest_slot({'cron': cron, 'clock': 'CLOCK_LOCAL'}, 10000)

    def test_success_needs_real_snapshot(self):
        op = backup('STATUS_SUCCESS', 100, 1000, snapshotId='abc')
        self.assertIsNotNone(m.decision([op], 900, 10000))
        op['operationBackup']['dryRun'] = True
        self.assertIsNone(m.decision([op], 900, 10000))

    def test_partial_and_index_are_not_success(self):
        op = backup('STATUS_WARNING', 100, 1000, snapshotId='abc')
        index = dict(status='STATUS_SUCCESS', unixTimeEndMs=1000000, operationIndexSnapshot={})
        self.assertIsNone(m.decision([op, index], 900, 10000))

    def test_pending_future_does_not_hide_missing_backup(self):
        self.assertIsNone(m.decision([backup('STATUS_PENDING', 20000)], 900, 10000))
        self.assertIsNotNone(m.decision([backup('STATUS_PENDING', 10001)], 900, 10000))
        self.assertIsNotNone(m.decision([backup('STATUS_INPROGRESS', 100)], 900, 10000))

    def test_cooldown_and_scheduler_grace(self):
        self.assertIsNotNone(m.decision([], 900, 10000, submitted=9999))
        self.assertIsNotNone(m.decision([backup('STATUS_ERROR', 9900)], 900, 10000))
        self.assertIsNotNone(m.decision([], 9900, 10000))

    def test_disconnect_never_calls_api(self):
        with patch.object(m, 'drive_connected', return_value=False), patch.object(m, 'API') as api:
            m.run(False)
            api.assert_not_called()

    def test_timeout_submission_is_not_replayed(self):
        class FakeAPI:
            calls = []
            def call(self, method, payload, **kw):
                self.calls.append(method)
                if method == 'GetConfig':
                    return {'instance':'test', 'plans':[{'id':'seaback-daily','repo':'SeaBack',
                            'schedule':{'cron':'35 17 * * *','clock':'CLOCK_LOCAL'}}]}
                if method == 'GetOperations': return {'operations':[]}
                raise TimeoutError()
        with tempfile.TemporaryDirectory() as tmp, patch.object(m, 'STATE', Path(tmp)), \
                patch.object(m, 'PLANS', ('seaback-daily',)), \
                patch.object(m, 'drive_connected', return_value=True), patch.object(m, 'API', FakeAPI), \
                patch.object(m.time, 'time', return_value=dt.datetime(2026, 10, 27, 12).timestamp()):
            m.run(True)
            self.assertNotIn('Backup', FakeAPI.calls)
            m.run(False)
            m.run(False)
            self.assertEqual(FakeAPI.calls.count('Backup'), 1)


if __name__ == '__main__':
    unittest.main()
