local template = require 'resty.template'
template.caching(false)
template.render("template.html", { ngx = ngx, message_string = "I passed this in from resty_template.lua" })
