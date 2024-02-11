import "relay/choice.ash";
import "relay/BastilleRelay.ash"
//Choice	override

void main(string page_text_encoded)
{
	string page_text = page_text_encoded.choiceOverrideDecodePageText();
	handleBastille(page_text);
	
}