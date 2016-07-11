Api_Routes = require '../../src/controllers/Api-Routes'
Server     = require '../../src/server/Server'


describe 'controllers | Api-Routes', ->
  app = null

  beforeEach ->
    app = new Server().setup_Server().app

  it 'constructor', ->
    options = app: app
    using new Api_Routes(null), ->
      @.options.assert_Is {}
    using new Api_Routes(options), ->
      @             .constructor.name.assert_Is 'Api_Routes'
      @.app         .constructor.name.assert_Is 'EventEmitter'
      @.routes      .constructor.name.assert_Is 'Routes'
      @.router      .constructor.name.assert_Is 'Function'
      @.options.assert_Is options

  it 'add_Routes', ->
    using new Api_Routes(app:app), ->
      @.router.stack.assert_Size_Is 0 
      @.add_Routes()
      @.router.stack.assert_Size_Is 3

  it 'list_Fixed', ->
    req = 
      project: 'bsimm'
    res =      
      send: (data)->
        data.assert_Contains [ '/ping', '/routes/list', '/routes/list-raw']
        data.assert_Contains [ '/aaaa/bsimm/team-C']
        #data.assert_Contains [ 'demo']


    using new Api_Routes(app:app), ->
      @.add_Routes()
      @.app.use('routes', @.router)
      @.router.get '/aaaa/:project/:team'
      #@.router.get '/bbbb/:team'             # Issue 129 - Routes.list_Fixed add logic to also map other variables (like project)
      @.router.get '/cccc/:project'
      @.list_Fixed(req, res)

  it 'list_Raw', ->
    res =
      send: (data)->
        data.assert_Contains [ '/ping']
        data.assert_Contains [ '/aaaa/:filename']

    using new Api_Routes(app:app), ->
      @.app.use('routes', @.router)
      @.router.get '/aaaa/:filename'
      @.list_Raw(null, res)


      