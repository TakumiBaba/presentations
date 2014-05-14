Github = require "github-api"
fs = require "fs"
token = "b149a928af76eca571c91a4c80abf8e9f005c707"

github = new Github
  token: token
  auth: "oauth"

filename = process.argv[2]
fs.readFile "table.json", (err, d)->
  id = null
  if d.toString()?
    json = JSON.parse d
    id = json[filename]
  fs.readFile filename, (err, data)->
    throw err if err
    body = data.toString()
    if id
      updateGist(id, body, json)
    else
      createGist(body, json)
updateGist = (id, body, json)->
  gist = github.getGist id
  gist.read (err, g)->
    d =
      description: g.description
      files: {}
    d.files[filename] = {content: body}
    gist.update d, (err)->

createGist = (body, json)->
  gist = github.getGist()
  options =
    description: "presentation files"
    public: true
    files: {}
  options.files["#{filename}"] = {content: body}
  gist.create options, (err, res)->
    id = res.id
    json[filename] = id
    d = JSON.stringify json
    fs.writeFile "table.json", d, (err)->
