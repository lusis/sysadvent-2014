function getLuaCode(file, toUpdate) {
	$.ajax({url: "/code/lua/"+file,
		type: "GET",
		dataType: 'text',
		success: function(data) { 
			$("#"+toUpdate).text(data);
			return false; }
	});
}
