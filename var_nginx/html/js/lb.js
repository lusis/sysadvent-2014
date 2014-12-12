var prefix = "ws:";
if (window.location.protocol === "https") prefix = "wss:";
var lbws_url = prefix+"//"+window.location.hostname+":"+window.location.port+"/lbws";
var ws = null;

function connect() {
  if (ws !== null) return log('already connected');
  ws = new WebSocket(lbws_url);
  ws.onopen = function () {
    log('connected');
  };
  ws.onerror = function (error) {
    log(error);
  };
  ws.onmessage = function (e) {
    log('recv: ' + e.data);
    var tableData = new Array();
    if (e.data === "connected") {
      //Do nothing
    } else {
      var j = JSON.parse(e.data);
      _.each(j, function(value, key) {
        log(key+" = "+value);
        tableData.push([key, value]);
      })
    }
    updateTable(tableData);
    return false;
  };
  ws.onclose = function () {
    log('disconnected');
    ws = null;
  };
  return false;
}
function disconnect() {
  if (ws === null) return log('already disconnected');
  ws.close();
  return false;
}
function send() {
  if (ws === null) return log('please connect first');
  ws.send(text);
  return false;
}

function updateTable(tableData) {
  $('#loadbalancers').dataTable( { data: tableData, destroy: true } ); 
}

function log(text) {
  console.log(text);
  return false;
}
$(document).ready(function() {
  $('#loadbalancers').dataTable();
});
