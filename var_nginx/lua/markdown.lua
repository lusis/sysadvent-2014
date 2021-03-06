-- lua-httpclient ships with a better url/uri parser
local neturl = require 'httpclient.neturl'

-- load the template stuff
local template = require 'resty.template'

-- We need to read files with something that reads our files and then wraps the response
-- in the markdown parsing syntax
-- based off https://github.com/bungle/lua-resty-template/blob/master/lib/resty/template.lua#L44-L50
local function load_wrapper(s)
  ngx.log(ngx.INFO, "Going to read: ",s)
  local file = io.open(ngx.var.template_root.."/"..s, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  local prestyle = "<style>pre { background-color: black; color: grey; padding: 0px 5px 5px 5px;}</style>"
  local toc = "{*markdown([["..content.."]], {extensions = {'fenced_code', 'tables', 'quote'}, renderer = 'html.toc', nesting = 2})*}"
  return bootstrap_header..prestyle.."<div class='row'>".."{*markdown([["..content.."]], {extensions = {'fenced_code', 'tables', 'quote'}, renderer = 'html', nesting = 2})*}</div>"..bootstrap_footer
end
template.load = load_wrapper
template.caching(false)
template.markdown = require "resty.hoedown"

-- following helper function was cribbed from the fine folks at 3scale
-- https://github.com/3scale/nginx-oauth-templates/blob/master/oauth2/authorization-code-flow/no-token-generation/nginx.lua#L76-L90
function string:split(delimiter)
  local result = { }
  local from = 1
  local delim_from, delim_to = string.find( self, delimiter, from )
  
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from )
  end
  
  table.insert( result, string.sub( self, from ) )
  
  return result
end

-- split the path into parts and then get the last element
local paths = string.split(neturl.parse(ngx.var.uri).path, "/")
local doc = paths[#paths]
template.render(doc)
