################################################################################
### CompanyCam - Entities
################################################################################
add_link_gsub 'CCAM',                                  page: 'CompanyCam'
add_link_gsub '16MBP',  alias: 'CCAM-16MBP',           page: 'CompanyCam 16" MacBook Pro'
add_link_gsub 'PTEAM',  alias: 'Platform Team',        page: 'CompanyCam Platform Team'


################################################################################
### CompanyCam - People
################################################################################
add_link_gsub 'ALISON',   page: 'Alison Chan',        alias: 'Alison'
add_link_gsub 'AUSTIN',   page: 'Austin Kostelansky', alias: 'Austin'
add_link_gsub 'COURTNEY', page: 'Courtney White',     alias: 'Courtney'
add_link_gsub 'DUSTIN',   page: 'Dustin Fisher',      alias: 'Dustin'
add_link_gsub 'GREG',     page: 'Greg Brinker',       alias: 'Greg'
add_link_gsub 'JAREDS',   page: 'Jared Stauffer',     alias: 'Jared S.'
add_link_gsub 'JASON',    page: 'Jason Gaare',        alias: 'Jason'
add_link_gsub 'JEFF',     page: 'Jeff McFadden',      alias: 'Jeff'
add_link_gsub 'JOSE',     page: 'Jose Cartagena',     alias: 'Jose'
add_link_gsub 'LEA',      page: 'Lea Sheets',         alias: 'Lea'
add_link_gsub 'MATT',     page: 'Matt Melnick',       alias: 'Matt'
add_link_gsub 'MUNYO',    page: 'Munyo Frey',         alias: 'Munyo'
add_link_gsub 'RACHEL',   page: 'Rachel Bryant',      alias: 'Rachel'
add_link_gsub 'REID',     page: 'Reid Alt',           alias: 'Reid'
add_link_gsub 'SHAUN',    page: 'Shaun Garwood',      alias: 'Shaun'
add_link_gsub 'SILVIA',   page: 'Silvia Marmol',      alias: 'Silvia'


################################################################################
### CompanyCam - Projects
################################################################################
add_link_gsub 'AMPFF',                              page: 'Amplitude Feature Flags'
add_link_gsub 'BLINC',  alias: 'Blinc Improvments', page: 'Blinc Improvements Jun 2025'
add_link_gsub 'CAMJAM', alias: 'CamJam',            page: 'CamJam 2025'

################################################################################
### Slack
################################################################################
# Channel shortcuts, these are above the escape gsub so they will be automatically escaped
add_gsub '#DK',   '#data-kitchen'
add_gsub '#DB',   '#platform-divebar'
add_gsub '#BE',   '#backend-engineers'
add_gsub '#TAIL', '#tod-ai-learned'
add_gsub '#DEVR', '#dev-random'

# Escape channel names in code blocks so they dont turn into Obsidian tags
add_gsub /#[-a-z0-9]+/i do |entry, match|
  dbug "SLACK-CHANNEL: #{match}"
  "`#{match}`"
end
