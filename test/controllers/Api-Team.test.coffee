Api_Team = require '../../src/controllers/Api-Team'

describe 'controllers | Api-Team', ->
  api_Team = null
  project  = null

  before ->
    project = 'bsimm'
    using new Api_Team(), ->
      api_Team = @

  it 'constructor', ->
    using api_Team, ->
      @.constructor.name.assert_Is 'Api_Team'
      @.router.assert_Is_Function()
      @.data_Team.constructor.name.assert_Is 'Data_Team'

  it 'add_Routes', ->
    using api_Team, ->
      @.add_Routes()
      @.router.stack.assert_Size_Is 5

  it 'delete', ->
    using api_Team, ->
      team_Name = @.data_Team.new_Team project
      req = params : project : project , team : team_Name
      res = send: (data)-> data.status.assert_Is 'Team Deleted'
      api_Team.delete(req, res)

  it 'delete (no project)', ->
    req = params : null
    res = send: (data)-> data.error.assert_Is 'Team deletion failed'
    api_Team.delete(req, res)

  it 'get', ->
    req =
      params :
        project: project
        team:    'team-A'
    res =
      setHeader: (name, value)->
        name.assert_Is 'Content-Type'
        value.assert_Is 'application/json'
      send: (data)->
        data.metadata.team.assert_Is 'Team A'

    using api_Team, ->
      @.get(req, res)

  it 'get (pretty)', ->
    req =
      params :
        project: project
        team   : 'team-A'
      query:
        pretty : ''
    res =
      setHeader: (name, value)->
        name.assert_Is 'Content-Type'
        value.assert_Is 'application/json'
      send: (data_pretty)->
        data_pretty.assert_Contains '"team": "Team A"'
        assert_Is_Undefined data_pretty.metadata
        data = data_pretty.json_Parse()
        data.metadata.team.assert_Is 'Team A'

    using api_Team, ->
      @.get(req, res)

  it 'get (bad data)', ->
    req = params : null
    res = 
      send: (data)->
        data.assert_Is {error: 'not found' }
    using api_Team, ->
      @.get(req, res)

  it 'new', ->
    req = params : project : project
    res = send: (data)-> data.status.assert_Is 'Ok'
    api_Team.new(req, res)

  it 'new (no project)', ->
    req = params : null
    res = send: (data)-> data.error.assert_Is 'New team creation failed'
    api_Team.new(req, res)
    
  it 'list', ->
    req =
      params: project: project
    res =
      send: (data)->
        data.assert_Size_Is_Bigger_Than 3
        data.assert_Contains [ 'team-A', 'team-B' ]
        data.duplicates().assert_Is []


    using api_Team, ->
      @.data_Team.data_Project.data_Path.assert_Folder_Exists()
      @.list(req,res)

  it 'save', ->
    data_Path = api_Team.data_Team.data_Project
                        .data_Path.assert_Folder_Exists()

    data_Path = data_Path.path_Combine 'BSIMM-Graphs-Data'
    data_Path.assert_Folder_Exists()
    
    file_Name    = "tmp-file"
    file_Path    = "#{data_Path}/teams/#{file_Name}.json"

    initial_Data = { initial: 'data' }
    changed_Data = { other  : 'data' }

    file_Path.file_Write initial_Data.json_Str()
    api_Team.data_Team.data_Project.clear_Caches()
    req =
      params:
        project: project
        team   : file_Name
      body     : changed_Data.json_Str()

    res =
      send: (data)->
        file_Path.file_Contents().assert_Is changed_Data.json_Str()
        data.assert_Is { status: 'file saved ok'}
        file_Path.assert_File_Deleted()

    using api_Team, ->
      @.save req, res

  it 'save (bad file)', ->
    req =
      params: filename: 'aaaa'
      body  : 'bbb'
    res =
      send: (data)->
        data.assert_Is { error: 'save failed'}

    using api_Team, ->
      @.save req, res