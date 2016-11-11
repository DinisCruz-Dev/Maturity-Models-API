Data_Radar   = require '../../../src/backend/Data-Radar'
Data_Team    = require '../../../src/backend/Data-Team'
Data_Project = require '../../../src/backend/Data-Project'

describe 'bugs | backend | Data-Project', ->


  it 'JS Decimal bug is causing Radar calculations to be wrong #80', ->
    project      = 'bsimm'
    team         = 'team-A'
    data_Radar   = new Data_Radar()
    data_Team    = new Data_Team()
    test_Data    = data_Team.get_Team_Data(project, team)
    radar_Fields = data_Radar.get_Radar_Fields project
    result       = data_Radar.map_Data radar_Fields, test_Data

    wrong_Value   = 0.6000000000000001
    result['CMVM'].assert_Is_Not wrong_Value          # was wrong value originally
    result['SE'  ].assert_Is_Not wrong_Value

    result['CMVM'].assert_Is 1.0714
    result['SE'  ].assert_Is 1.25

  it 'Fix Radar bug in OwaspSAMM graph - #164', ->
    project = 'samm'
    using  new Data_Radar(), ->
      using @.get_Radar_Fields(project), ->
        @.axes.assert_Size_Is 12
        @.axes.second().assert_Is_Not { axis: "Conf & Vuln Management" , xOffset: -110, value: 0}    # this was wrong (using BSIMM value)
        @.axes.second().assert_Is_Not { axis: "Operational Enablement" , xOffset: -110, value: 0}    # this is what it should be (SAMM value)



  it 'Fix Radar bug in OwaspSAMM graph - #164 (prob with get_Radar_Data)', ->
    project = 'samm'
    team    = 'level-1'
    using  new Data_Radar(), ->
      using @.get_Radar_Data(project,team), ->
        @.axes.assert_Size_Is 12
        @.axes[0  ].value.assert_Is 1.125
        @.axes[1  ].value.assert_Is 1
        @.axes[11 ].value.assert_Is 1
        (@.axes[0 ].value is undefined).assert_Is_False()
        (@.axes[1 ].value is undefined).assert_Is_False()
        (@.axes[11].value is undefined).assert_Is_False()
        (@.axes[12]       is undefined).assert_Is_True()



  it 'Fix Radar bug in OwaspSAMM graph - #164 (map_Data method)  ', ->
    keys_BSIMM = [ 'SM', 'CP', 'T' , 'AM', 'SFD', 'SR', 'AA', 'CR', 'ST', 'PT', 'SE', 'CMVM' ]
    keys_SAMM  = [ 'SM', 'PC', 'EG', 'TA', 'SR' , 'SA', 'DR', 'IR', 'ST', 'IM', 'EH', 'OE'   ]
    data_Radar = new Data_Radar()
    data_Team  = new Data_Team()
    team_Data_SAAM   = data_Team.get_Team_Data 'samm' , 'level-1'
    team_Data_BSIMM  = data_Team.get_Team_Data 'bsimm', 'level-1'

    radar_Fields_SAMM  = data_Radar.get_Radar_Fields 'samm'
    radar_Fields_BSIMM = data_Radar.get_Radar_Fields 'bsimm'
    mapping_SAMM       = data_Radar.map_Data radar_Fields_SAMM, team_Data_SAAM
    mapping_BSIMM      = data_Radar.map_Data radar_Fields_BSIMM, team_Data_BSIMM


    mapping_BSIMM._keys().assert_Is keys_BSIMM          # ok
    mapping_SAMM ._keys().assert_Is keys_SAMM           # ok

  it 'Performance issue on multiple Data_Project methods #167', ->
    start = Date.now()

    using new Data_Project(), ->
      @.clear_Caches()
      @.projects()._keys().size().assert_Is 2                             # there are 2 projects
      (Date.now() - start).assert_Smaller_Than 10                         # @.projects() is usually 2 ms (can be slower on wallaby due to parallel execution)

      for i in [1..400]                                                   # call @.project_Files 400 times (this used to be a problem with 10x )
        @.project_Files('bsimm')['team-A'].assert_File_Exists()           # there are about 315 projects in the current wallaby folder environment
      (Date.now() - start).assert_Smaller_Than 250                        # 10x @.project_Files() takes more than 250ms
  #   this becomes a problem for actions like
  #   calculate scores which will call @.project_Files
  #   once per project (i.e. 150+ times)

  it 'Data_Team.team_Path DoS when using non-existing team names #169', ->
    start = Date.now()
    using new Data_Team(), ->
      for i in [1..40]
        (@.team_Path('bsimm', 'team-A')).assert_File_Exists()           # using 'team-A' for team
      (Date.now() - start).assert_Smaller_Than 100                     # fast when team exists
      for i in [1..1000]
        assert_Is_Null @.team_Path('bsimm', 'aaaa')                     # using 'aaaa' for team
      (Date.now() - start).assert_Smaller_Than 100