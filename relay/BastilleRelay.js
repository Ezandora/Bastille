var __relay_url = "BastilleRelay.ash";


function processRelayReply(reply)
{
	document.open("text/html");
	document.write(reply);
	document.close();
}

function bastilleConfigurationButtonClicked(display_name)
{
	var form_data = "relay_request=true&type=configuration_button_clicked&button=" + display_name;
	var request = new XMLHttpRequest();
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { processRelayReply(request.responseText); } } }
	request.open("POST", __relay_url);
	request.send(form_data);
}

function bastilleCollectRewardsButtonClicked()
{
	var form_data = "relay_request=true&type=collect_reward_button_clicked";
	var request = new XMLHttpRequest();
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { processRelayReply(request.responseText); } } }
	request.open("POST", __relay_url);
	request.send(form_data);
}