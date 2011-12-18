function log(str){ console.log(str); }

function list_markup(name, id){
	return "<a href=\"#" + name + "\" data-id=\"" + id + "\">" + name + "<span>x</span></a>";
}

function task_markup(name, id, completed){
	if(completed) return "<li class=\"completed\" data-id=\"" + id + "\">" + name + "<span>x</span></li>";
	else return "<li data-id=\"" + id + "\">" + name + "<span>x</span></li>";
}

$(function(){
	$new_list_input = $("#lists input");
	$new_task_input = $("#tasks input");
	$lists_container = $("#lists nav");
	$tasks_container = $("#tasks");
	$tasks_list = $("#tasks ul");
	$list = $("nav a");
	$task = $("li");
	$list_delete_button = $("nav a span");
	$task_delete_button = $("li span");
	
	var selectedListId = -1;
	
	ENTER_KEY = 13;
	
	$tasks_container.hide();
	
	// get lists
	
	$.getJSON("/lists", function(data){
		for( var i = 0; i < data.length; i++){
			$lists_container.append( list_markup(data[i].name, data[i].id) );
		}	
	});
	
	$new_list_input.keyup(function(e){
		if(e.keyCode == ENTER_KEY){
			$.ajax({
				type: "POST",
				url: "/list/create",
				data: { list: { name: $new_list_input.val() }},
				dataType: "json"				
			}).done(function(r){
				if( r.error == null	 ){ // everything is okay
					$lists_container.prepend( list_markup(r.list.name, r.list.id) );
					$listWithId(r.list.id.toString()).hide().slideDown(500);
					selectList(r.list.id);
				}
				$new_list_input.val("");
			});
		}
	});
	
	$new_task_input.keyup(function(e){
		if( selectedListId == -1 ) return;
		if(e.keyCode == ENTER_KEY){
			$.ajax({
				type: "POST",
				url: "/task/create/" + selectedListId,
				data: { task: { name: $new_task_input.val() }},
				dataType: "json"			
			}).done(function(r){
				if( r.error == null ){
					var completed = r.task.state == "incomplete" ? false : true;
					$tasks_list.prepend( task_markup(r.task.name, r.task.id, completed) );
					$taskWithId(r.task.id).hide().slideDown(500);
				}
				$new_task_input.val("");
			});
		}
	})
	
	$list.live("click", function(e){
		if( $(e.target).text() == "x" ) return; // not if we clicked the 'x'
		e.preventDefault();
		selectList($(this).data("id"));
	});
	
	$task.live("click", function(e){
		e.preventDefault();
		$item = $(this);
		newState = $(this).hasClass("completed") ? "incomplete" : "completed";
		
		$.ajax({
			type: "POST",
			url: "/task/state/" + $item.data("id"),
			data: { state: newState },
			dataType: "json"
		}).done(function(r){
			if( r.error == null ){
				if(newState == "incomplete") $item.removeClass("completed");
				else $item.addClass("completed");
			}
		});
		
	});
	
	$list_delete_button.live("click", function(e){
		e.preventDefault();
		var $item = $(this).parent();
		var id = $(this).parent().data("id");
		$.ajax({
			type: "POST",
			url: "/list/destroy/" + id,
			dataType: "json"
		}).done(function(r){
			if( r.error == null ){
				$item.slideUp(300, function(){ $item.remove(); });
			}
		})
	});
	
	$task_delete_button.live("click", function(e){
		e.preventDefault();
		var $item = $(this).parent();
		var id = $(this).parent().data("id");
		$.ajax({
			type: "POST",
			url: "/task/destroy/" + id,
			dataType: "json"
		}).done(function(r){
			if( r.error == null ){
				$item.slideUp(300, function(){ $item.remove(); });
			}
		})
	});
	
	function selectList(id){
		$("nav a.selected").removeClass("selected");
		$listWithId(id).addClass("selected");

		selectedListId = id;
		
		$.getJSON("/tasks/" + id, function(data){
			log(data);
			$tasks_container.fadeIn(300);
			$tasks_list.html("");
			for( var i = 0; i < data.length; i++){
				var completed = data[i].state == "incomplete" ? false : true;
				$tasks_list.append( task_markup( data[i].name, data[i].id, completed ) );
			}
		});
	}	
	
	function $listWithId(id){
		return $("nav a[data-id=" + id + "]");
	}
	
	function $taskWithId(id){
		return $("li[data-id=" + id + "]");
	}
	
});