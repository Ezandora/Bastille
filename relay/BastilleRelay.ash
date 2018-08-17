import "scripts/bastille.ash";

boolean __setting_display_inaccurate_data = my_id() == 1557284 && true;






Record CheeseDataEntry
{
	string name;
	int turn;
	int relevant_stat_value;
	int cheese_gained;
};

int [string] relevantStatsForButton(string button_text)
{
	int [string] relevant_stats;
	if (button_text == "Put on the bad art show")
		relevant_stats["Psychological defense"] = -1;
	else if (button_text == "Enter the childrens' art contest")
		relevant_stats["Psychological attack strength"] = -1;
	else if (button_text == "Try the wall thing")
		relevant_stats["Castle defense"] = 1;
	else if (button_text == "Raid the cave")
		relevant_stats["Military attack strength"] = 1;
	else if (button_text == "Convert the barracks")
		relevant_stats["Military defense"] = 1;
	else if (button_text == "Raid the cart" || button_text == "Grab the boulder" || button_text == "Scrape out the mine")
		relevant_stats["none"] = 1;
	else if (button_text == "Enter the Weakest Army competition")
		relevant_stats["Military attack strength"] = -1;
	else if (button_text == "Let the cheese horse in")
		relevant_stats["Military defense"] = -1;
	else if (button_text == "Shoot the glacier")
		relevant_stats["Castle attack strength"] = 1;
	else if (button_text == "Stand in the waterfall")
		relevant_stats["Castle defense"] = -1;
	else if (button_text == "Have the cheese contest")
		relevant_stats["Psychological defense"] = 1;
	else if (button_text == "Rob the suburb")
		relevant_stats["Psychological attack strength"] = 1;
	else if (button_text == "Submit embarrassing catapult photos")
		relevant_stats["Castle attack strength"] = -1;
	return relevant_stats;
}

int __hack_average_cheese_samples = 0;
float calculateAverageCheeseGained(CheeseDataEntry [int] cheese_data, string button_text)
{
	__hack_average_cheese_samples = 0;
	int [string] relevant_stats = relevantStatsForButton(button_text);
	int relevant_stat_index = -1;
	foreach stat_name in relevant_stats
	{
		if (__stat_name_to_index contains stat_name)
			relevant_stat_index = __stat_name_to_index[stat_name];
	}
	float average_cheese_gained = 0;
	int average_cheese_count = 0;
	foreach key, entry in cheese_data
	{
		if (entry.name != button_text) continue;
		if (relevant_stat_index != -1 && __bastille_state.stats[relevant_stat_index] != entry.relevant_stat_value) continue;
		average_cheese_gained += entry.cheese_gained;
		average_cheese_count += 1;
	}
	if (average_cheese_count != 0)
		average_cheese_gained /= to_float(average_cheese_count);
	__hack_average_cheese_samples = average_cheese_count;
	
	
	if (average_cheese_count == 0 && relevant_stat_index != -1)
	{
		average_cheese_gained = 0.0;
		//Simple linear regression:
		float x_sum = 0.0;
		float y_sum = 0.0;
		float xy_sum = 0.0;
		float x_squared_sum = 0.0;
		float y_squared_sum = 0.0;
		float n = 0.0;
		foreach key, entry in cheese_data
		{
			if (entry.name != button_text) continue;
			if (entry.relevant_stat_value <= 0.0) continue;
			
			float x = entry.relevant_stat_value;
			float y = entry.cheese_gained;
			
			x_sum += x;
			y_sum += y;
			xy_sum += x * y;
			x_squared_sum += x * x;
			y_squared_sum += y * y;
			n += 1;
		}
		float a = y_sum * x_squared_sum - x_sum * xy_sum;
		float denom = n * x_squared_sum - x_sum * x_sum;
		if (denom != 0.0)
			a /= denom;
		else
			return 0.0;
		float b = n * xy_sum - x_sum * y_sum;
		denom = n * x_squared_sum - x_sum * x_sum;
		if (denom != 0.0)
			b /= denom;
		else
			return 0.0;
		
		average_cheese_gained = b * __bastille_state.stats[relevant_stat_index] + a;
	}
	return average_cheese_gained;
}


int calculateFinalStatgain(int stats_gained, stat stat_type)
{
	float experience_percent = numeric_modifier(stat_type + " experience percent");
	return stats_gained * (1.0 + experience_percent / 100.0);
}

string layoutEntriesAsUnwrappable(string [int] entries)
{
	string [int] entries_2;
	foreach key, entry in entries
	{
		entries_2.listAppend("<span style=\"display:inline-block;\">" + entry + "</span>");
	}
	
	return entries_2.listJoinComponents(", ");
}

void layoutBastilleOptions(string page_text, buffer extra_text, boolean allow_choosing)
{
	if (!page_text.contains_text("otherimages/bbatt/start.png")) return; //out of charges
	//extra_text.append("<div style=\"display:table;width:100%;\">");
	//extra_text.append("<div style=\"display:table-row;\">");
	if (!allow_choosing) return; //no real information to be gained, I think? just noise
	boolean already_locked_in_score_today = to_item("Brutal brogues").available_amount() > 0 || to_item("Draftsman's driving gloves").available_amount() > 0 || to_item("Nouveau nosering").available_amount() > 0;
	//foreach configuration_type, configuration_value in __bastille_state.configuration
	//string [int] configuration_evaluation_order = {"barb", "moat", "bridge", "holes"};
	
	string [int][int] table;
	boolean [int][int] table_selected;
	string [int][int] table_onclick;
	boolean [int][int] table_not_a_button;
	string [int] configuration_evaluation_order = {"barb", "bridge", "holes", "moat"};
	foreach key, configuration_type in configuration_evaluation_order
	{
		int configuration_value = __bastille_state.configuration[configuration_type];
		string active_display_name = __configuration_internals_to_display_name[configuration_type][configuration_value];
		
		string [int] evaluating_options;
		if (!allow_choosing)
			evaluating_options = {active_display_name};
		else
		{
			if (configuration_type == "barb")
				evaluating_options = {"BABAR", "BARBARIAN BARBECUE", "BARBERSHOP"};
			if (configuration_type == "bridge")
				evaluating_options = {"BRUTALIST", "DRAFTSMAN", "ART NOUVEAU"};
			if (configuration_type == "holes")
				evaluating_options = {"CANNON", "CATAPULT", "GESTURE"};
			if (configuration_type == "moat")
				evaluating_options = {"SHARKS", "LAVA", "TRUTH SERUM"};
		}
		if (!already_locked_in_score_today)
		{
			table[-1][key] = "<span style=\"font-weight:bold\">" + active_display_name + "</span>";
			table_not_a_button[-1][key] = true;
		}
		//extra_text.append("<div style=\"padding:5px;display:table-cell;background:#DDDDDD;border-radius:5px;cursor:pointer;text-align:center;vertical-align:middle;width:25%;\">");
		//extra_text.append("<div style=\"display:table;\">");
		foreach key2, display_name in evaluating_options
		{
			string image_name = "/images/itemimages/confused.gif";
			string description = "???";
		
			if (display_name == "BARBARIAN BARBECUE")
			{
				image_name = "/images/itemimages/tinystars.gif";
				description = calculateFinalStatgain(250, $stat[mysticality]) + " myst stats";
			}
			else if (display_name == "BABAR")
			{
				image_name = "/images/itemimages/fitposter.gif";
				description = calculateFinalStatgain(250, $stat[muscle]) + " muscle stats";
			}
			else if (display_name == "BARBERSHOP")
			{
				image_name = "/images/itemimages/greaserint.gif";
				description = calculateFinalStatgain(250, $stat[moxie]) + " moxie stats";
			}
			else if (display_name == "ART NOUVEAU")
			{
				image_name = "/images/itemimages/bbattnosering.gif";
				description = "Nouveau nosering";
				description += "<br><small>" + listMake("+50% moxie", "+25% item", "+25 HP/MP", "+4 moxie stats/fight").layoutEntriesAsUnwrappable() + "</small>";
			}
			else if (display_name == "BRUTALIST")
			{
				image_name = "/images/itemimages/bbattshoes.gif";
				description = "Brutal brogues";
				description += "<br><small>" + listMake("+50% muscle", "+50% weapon damage", "+8 familiar weight", "+4 muscle stat/fight").layoutEntriesAsUnwrappable() + "</small>";
			}
			else if (display_name == "DRAFTSMAN")
			{
				image_name = "/images/itemimages/bbattgloves.gif";
				description = "Draftsman's driving gloves";
				description += "<br><small>" + listMake("+50% myst", "+50% spell damage", "+8 adventures/day", "+4 myst stat/fight").layoutEntriesAsUnwrappable() + "</small>";
			}
			else if (display_name == "SHARKS")
			{
				image_name = "/images/itemimages/potion17.gif";
				description = "Sharkfin gumbo";
				description += "<br><small>+military attack/def</small>";
			}
			else if (display_name == "LAVA")
			{
				image_name = "/images/itemimages/wbpotion.gif";
				description = "Boiling broth";
				description += "<br><small>+castle attack/def</small>";
			}
			else if (display_name == "TRUTH SERUM")
			{
				image_name = "/images/itemimages/potion15.gif";
				description = "Interrogative elixir";
				description += "<br><small>+psychological attack/def</small>";
			}
			else if (display_name == "CANNON")
			{
				image_name = "/images/itemimages/strboost.gif";
				description = "Bastille Budgeteer<br><small>(100 turns)</small>";
				description += "<br><small>" + listMake("+25 muscle", "+10% critical hit", "+15 HP/adventure").layoutEntriesAsUnwrappable() + "</small>";
			}
			else if (display_name == "CATAPULT")
			{
				image_name = "/images/itemimages/snowflakes.gif";
				description = "Bastille Bourgeoisie<br><small>(100 turns)</small>";
				description += "<br><small>" + listMake("+25 myst", "+10% spell critical hit", "+7.5 MP/adventure").layoutEntriesAsUnwrappable() + "</small>";
			}
			else if (display_name == "GESTURE")
			{
				image_name = "/images/itemimages/shadesface.gif";
				description = "Bastille Braggadocio<br><small>(100 turns)</small>";
				description += "<br><small>" + listMake("+25 moxie", "+25% init", "+25% meat").layoutEntriesAsUnwrappable() + "</small>";
			}
			boolean avoid_displaying_extra = false;
			if (already_locked_in_score_today) //score locked in, rewards impossible to obtain - confusingly change the description.
				avoid_displaying_extra = true;
			buffer entry;
			//extra_text.append("<div style=\"display:inline-block;width:25%;\">");
			//extra_text.append("<div style=\"display:table;width:100%;\">");
			//extra_text.append("<div style=\"display:table-row;\">");
		
		
			//extra_text.append("<div style=\"display:table-row;\">");
			//extra_text.append("<div style=\"display:table-cell;\">");
			/*entry.append("<div style=\"position:relative;\">");
			entry.append("<div style=\"position:absolute;top:0;left:auto;right:auto;\">" + display_name + "</div>");
			entry.append("</div>");*/
			//entry.append(display_name + "<br>");
			entry.append("<img src=\"" + image_name + "\" style=\"mix-blend-mode:multiply;\" width=\"30\" height=\"30\">");
			//extra_text.append("<br>" + display_name);
			entry.append("<br>" + description);
			//extra_text.append(configuration_type + ": " + display_name);
			//extra_text.append("</div>");
			//extra_text.append("</div>");
			//extra_text.append("</div>");
			//extra_text.append("</div>");
			//extra_text.append("</div>");
			
			if (avoid_displaying_extra)
			{
				entry.set_length(0);
				entry.append(display_name);
			}
			if (display_name == active_display_name && evaluating_options.count() > 1)
			{
				table_selected[key2][key] = true;
				//table_selected[key2 * 2][key] = true;
				//table_selected[key2 * 2 + 1][key] = true;
			}
			else
				table_onclick[key2][key] = "bastilleConfigurationButtonClicked('" + display_name + "');";
			table[key2][key] = entry;
			//table[key2 * 2][key] = display_name;
			//if (!avoid_displaying_extra)
				//table[key2 * 2 + 1][key] = entry;
		}
		//extra_text.append("</div>");
		//extra_text.append("</div>");
	}
	//extra_text.append("</div>");
	//extra_text.append("</div>");
	
	extra_text.append("<div style=\"display:table;width:100%;\">");
	foreach row in table
	{
		extra_text.append("<div style=\"display:table-row;\">");
		foreach column in table[row]
		{
			boolean is_button = !table_not_a_button[row][column];
			string class_name = "bastille_table_cell_button";
			if (is_button)
				class_name += " bastille_button";
			string style = "";//"padding-top:5px;padding-bottom:5px;display:table-cell;border-radius:5px;text-align:center;vertical-align:middle;width:25%;";
			if (allow_choosing)
			{
				//style += "cursor:pointer;";
				if (table_selected[row][column] || !is_button)
					style += "cursor:default;";
				else
					class_name += " bastille_button_selectable";
			}
			if (table_selected[row][column])
			{
				//style += "background:#DDDDDD;";
				class_name += " bastille_button_selected";
			}
			extra_text.append("<div style=\"" + style + "\" class=\"" + class_name + "\"");
			if (table_onclick[row][column] != "")
			{
				extra_text.append(" onclick=\"" + table_onclick[row][column] + "\"");
			}
			extra_text.append(">");
			extra_text.append(table[row][column]);
			extra_text.append("</div>");
		}
		extra_text.append("</div>");
	}
	extra_text.append("</div>");
	if (!already_locked_in_score_today)
		extra_text.append("<div class=\"bastille_button bastille_button_selectable\" style=\"font-size:1.5em;font-weight:bold;padding:10px;\" onclick=\"bastilleCollectRewardsButtonClicked();\">Collect rewards</div>");
	
	
}

void handleBastille(string page_text)
{
	BastilleStateParse(page_text, true);
	
	buffer extra_text;
	buffer extra_top_text;
	//write(page_text);
	
	if (__bastille_state.current_choice_adventure_id <= 0)
	{
		write(page_text);
		return;
	}
	
	PageAddCSSClass("", "bastille_button", "padding-top:5px;padding-bottom:5px;border-radius:5px;text-align:center;");
	PageAddCSSClass("", "bastille_table_cell_button", "display:table-cell;text-align:center;vertical-align:middle;width:25%;");
	PageAddCSSClass("", "bastille_button_selectable", "cursor:pointer;");
	PageAddCSSClass("", "bastille_button_selectable:hover", "background:#CCCCCC;");
	PageAddCSSClass("", "bastille_button_selected", "background:#CCCCCC;");
	
	extra_top_text.append(PageGenerateStyle());
	extra_top_text.append("<script type=\"text/javascript\" src=\"BastilleRelay.js\"></script>");
	
	
	layoutBastilleOptions(page_text, extra_text, __bastille_state.current_choice_adventure_id == 1313);
	
	CheeseDataEntry [int] cheese_data;
	file_to_map("Bastille Cheese Data.txt", cheese_data);
	
	
	//string [int][int] needle_matches = page_text.group_string("<img style='position: absolute; top: ([0-9]+); left: ([0-9]+);'");
	int total_delta = 0;
	int total_attack_modifiers = 0;
	int total_defence_modifiers = 0;
	
	//int [int] last_stats = get_property("_lastBastilleStatsSeen").split_string_alternate(",").listConvertToInt();
	//int [int] stats;
	extra_text.append("<div style=\"display:table;text-align:left;\"><div style=\"display:table-row;\"><div style=\"display:table-cell;padding-right:10px;\">");
	int [int] stats_approximate_deltas;
	foreach stat_id, stat_value in __bastille_state.stats
	{
		int delta = stat_value - __needle_minimum_possible_value[stat_id];
		total_delta += delta;
		if (stat_id >= 0 && stat_id <= 2) total_attack_modifiers += delta;
		if (stat_id >= 3 && stat_id <= 5) total_defence_modifiers += delta;
		string needle_description = "Needle " + stat_id;
		if (stat_id == 0)
			needle_description = "Military attack strength";
		else if (stat_id == 1)
			needle_description = "Castle attack strength";
		else if (stat_id == 2)
			needle_description = "Psychological attack strength";
		else if (stat_id == 3)
			needle_description = "Military defense";
		else if (stat_id == 4)
			needle_description = "Castle defense";
		else if (stat_id == 5)
			needle_description = "Psychological defense";
		//stats[stat_id] = stat_value;
		stats_approximate_deltas[stat_id] = delta;
		if (stat_id == 3)
		{
			extra_text.append("</div><div style=\"display:table-cell;padding-left:10px;\">");
			//extra_text.append("<br>");
		}
		extra_text.append("<br>" + needle_description + ": <span style=\"font-weight:bold\">" + stat_value + "</span>");
		if (__setting_display_inaccurate_data)
			extra_text.append(" (" + (delta >= 0 ? "+" : "") + delta + ")");
		
		int delta_since_last = (stat_value - __bastille_state.last_stats_seen[stat_id]);
		if (delta_since_last != 0 && __bastille_state.last_stats_seen contains stat_id)
			extra_text.append(" <span style=\"color:red;\">[" + (delta_since_last > 0 ? "+" : "") + delta_since_last + "]</span>");
		
	}
	extra_text.append("</div></div></div>");
	extra_text.append("<br>");
	if (__setting_display_inaccurate_data)
		extra_text.append("<br>Total modifiers: +" + total_delta + ", Attack: +" + total_attack_modifiers + ", Defence: +" + total_defence_modifiers);
	
	
	
	if (__bastille_state.current_choice_adventure_id == 1317 || __bastille_state.current_choice_adventure_id == 1318 || __bastille_state.current_choice_adventure_id == 1319)
	{
		string [int][int] buttons = page_text.group_string("<input  class=button type=submit value=\"(.*?)\">");
		extra_text.append("<br>");
		foreach key in buttons
		{
			string button_text = buttons[key][1];
			extra_text.append("<br>" + button_text);
			int [string] relevant_stats = relevantStatsForButton(button_text);
			if (page_text.contains_text("Cheese Seeking Behavior"))
			{
				if (relevant_stats.count() == 0)
				{
				}
			}
			extra_text.append(": ");
			foreach stat_name, direction in relevant_stats
			{
				int absolute_value = __bastille_state.stats[__stat_name_to_index[stat_name]];
				int relative_value = stats_approximate_deltas[__stat_name_to_index[stat_name]];
				boolean bad = false;
				if (!(__stat_name_to_index contains stat_name))
				{
					absolute_value = -100000;
					relative_value = -100000;
					bad = true;
				}
				
				if (my_id() == 1557284 && true)
				{
					if (bad)
						extra_text.append("<span style=\"color:red;\">");
					else
						extra_text.append("<span style=\"color:green;\">");
					extra_text.append(absolute_value);
					if (!bad)
						extra_text.append("</span>");
					extra_text.append(" (");
					if (direction < 0)
						extra_text.append("<span style=\"color:red;\">");
					extra_text.append(relative_value);
					if (direction < 0)
						extra_text.append("</span>");
					extra_text.append(")");
					if (bad)
						extra_text.append("</span>");
				}
			}
			if (page_text.contains_text("Cheese Seeking Behavior"))
			{
				float cheese_gained = calculateAverageCheeseGained(cheese_data, button_text);
				if (cheese_gained != 0.0)
				{
					extra_text.append(" ~" + cheese_gained.round() + " cheese gained");
					if (my_id() == 1557284 && true)
						extra_text.append(" (" + __hack_average_cheese_samples + " samples)");
				}
			}
		}
	}
	
	
	string [int][int] image_names = page_text.group_string("/otherimages/bbatt/(.*?).png");
	string last_image = image_names[image_names.count() - 1][1].replace_string("_3", "");
	if (__bastille_state.current_choice_adventure_id == 1315)
	{
		extra_text.append("<br>");
		extra_text.append("Castle: " + last_image);
	}
	if (__bastille_state.current_choice_adventure_id != 1313)
	{
		extra_text.append("<div class=\"bastille_button bastille_button_selectable\" style=\"font-size:1.5em;font-weight:bold;padding:10px;\" onclick=\"bastilleCollectRewardsButtonClicked();\">Finish Game (and lose)</div>");
	}
	
	//extra_text.append("<br>Choice #" + __bastille_state.current_choice_adventure_id);
	
	
	
	
	string new_page_text = page_text.replace_string("</center></td></tr></table>", extra_text + "</center></td></tr></table>");
	
	if (new_page_text.contains_text("<table><tr><td><Center>"))
		new_page_text = new_page_text.replace_string("<table><tr><td><Center>", "<table><tr><td><Center>" + extra_top_text);
	else
		new_page_text = new_page_text.replace_string("<table><tr><td><center>", "<table><tr><td><center>" + extra_top_text);
	
	write(new_page_text);
}

void handleFormRelayRequest()
{
    string [string] form_fields = form_fields();
    string type = form_fields["type"];
    if (type == "configuration_button_clicked")
    {
    	buffer page_text;
    	string button = form_fields["button"];
    	boolean done = false;
    	foreach configuration_type in __configuration_internals_to_display_name
    	{
    		foreach configuration_value in __configuration_internals_to_display_name[configuration_type]
    		{
    			string configuration_display_name = __configuration_internals_to_display_name[configuration_type][configuration_value];
    			if (configuration_display_name == button)
    			{
    				page_text = bastilleChangeConfiguration(configuration_type, configuration_value);
    				done = true;
    				break;
    			}
    		}
    		if (done)
    			break;
    	}
    	
    	if (page_text.length() > 0)
    	{
    		handleBastille(page_text);
    	}
    	else
	    	write("<html></html>");
    }
    else if (type == "collect_reward_button_clicked")
    {
    	buffer page_text = bastilleStartFromChoiceAdventureAndSolveGame(false);
    	if (page_text.length() > 0)
    	{
    		handleBastille(page_text);
    	}
    	else
	    	write("<html></html>");
    }
}

void main()
{
    if (form_fields()["relay_request"] != "")
    {
        handleFormRelayRequest();
        return;
    }
}