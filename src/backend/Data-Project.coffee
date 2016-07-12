class Data_Project
  constructor: ()->
    @.data_Path       = __dirname.path_Combine('../../../../data')
    @.config_File     = "maturity-model.json"
    @.schema_File     = "schema.json"

  project_Files: (id)=>                                        # todo: refactor to make code clear
    return using (@.projects()[id]),->
      values = []
      if @?.path_Teams          
          for file in @.path_Teams.files_Recursive()          
            if file.file_Extension() in ['.json', '.coffee']
                values.push file
      return values

  project_Schema: (id)=>
    return using (@.projects()[id]),->
      if @.path_Schema?.file_Exists()
          return @.path_Schema.load_Json()
      return {}

  project_Path_Root: (project)=>
    projects = @.projects()                                 # this should be cached
    if projects[project]
      return projects[project].path_Root
    return null

  project_Path_Teams: (project)=>
    projects = @.projects()                                 # this should be cached
    if projects[project]
      return projects[project].path_Teams
    return null  

  # returns a list of current projects (which are defined by a folder containing an maturity-model.json )
  projects: ()=>
    projects = {}
    target_Folders  = @.data_Path?.folders()

    for folder in target_Folders
      config_File = folder.path_Combine @.config_File       # Issue: DoS on Data-Project technique to map projects and project's teams #108
      if config_File.file_Exists()
        data = config_File.load_Json()
        if data and data.key
          projects[data.key] = 
            path_Root  : folder
            path_Config: folder.path_Combine @.config_File
            path_Schema: folder.path_Combine @.schema_File
            path_Teams : folder.path_Combine 'teams'
            data: data    
    projects

  ids: ()=>
    @.projects()._keys()
      
module.exports = Data_Project

 