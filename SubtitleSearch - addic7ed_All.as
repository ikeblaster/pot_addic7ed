/*
	subtitle search for addic7ed.com
*/
 
//	string GetTitle() 																	-> get title for UI
//	string GetVersion																	-> get version for manage
//	string GetDesc()																	-> get detail information
//	string GetLoginTitle()																-> get title for login dialog
//	string GetLoginDesc()																-> get desc for login dialog
//	string ServerCheck(string User, string Pass) 										-> server check
//	string ServerLogin(string User, string Pass) 										-> login
//	void ServerLogout() 																-> logout
//	string GetLanguages()																-> get support language
//	string SubtitleWebSearch(string MovieFileName, dictionary MovieMetaData)			-> search subtitle bu web browser
//	array<dictionary> SubtitleSearch(string MovieFileName, dictionary MovieMetaData)	-> search subtitle
//	string SubtitleDownload(string id)													-> download subtitle
//	string GetUploadFormat()															-> upload format
//	string SubtitleUpload(string MovieFileName, dictionary MovieMetaData, string SubtitleName, string SubtitleContent)	-> upload subtitle

bool cookie = true;
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.58 Safari/537.36 Vivaldi/2.1.1332.4";
string Header = "Referer: http://www.addic7ed.com/";
string API_URL = "http://www.addic7ed.com/";
string API_LANGS = "|";

string GetTitle() {
	return "Addic7ed.com";
}

string GetVersion() {
	return "1";
}

string GetDesc() {
	return API_URL;
}

string GetLanguages() {
	return "";
}

string ServerCheck(string User, string Pass) {
	string ret = HostUrlGetString(API_URL);
	return "200 OK";
}

array<dictionary> SubtitleSearch(string MovieFileName, dictionary MovieMetaData) {
	array<dictionary> ret;
	
	string title = string(MovieMetaData["title"]);
	string seasonNumber = string(MovieMetaData["seasonNumber"]);
	string episodeNumber = string(MovieMetaData["episodeNumber"]);
	
	string showId = getShowId(title);
	string data = FetchData("/ajax_loadShow.php?hd=undefined&hi=-1&langs=" + API_LANGS + "&show=" + showId + "&season=" + seasonNumber);
	array<string> rows = data.split("<tr class=");
	
	for (int i = 0, len = rows.size(); i < len; i++) {
		string row = rows[i];
		array<dictionary> matches;
		
		if(row.find('>Download</a>') < 0) continue;
	
		if(HostRegExpParse(row,
						   "<td>([^>]*)</td>\\s*" + /* 1 ?<season> */
						   "<td>([^>]*)</td>\\s*" + /* 2 ?<episode> */
						   "<td><a[^>]+>([^<]+)</a></td>\\s*" + /* 3 ?<title> */
						   "<td>([^<]+)</td>\\s*" + /* 4 ?<language> */
						   "<td[^>]*>([^<]*)</td>\\s*" + /* 5 ?<version> */
						   "<td[^>]*>([^<]*)</td>\\s*" + /* 6 ?<completed> */
						   "<td[^>]*>([^<]*)</td>\\s*" + /* 7 ?<hi> */
						   "<td[^>]*>([^<]*)</td>\\s*" + /* 8 ?<corrected> */
						   "<td[^>]*>([^<]*)</td>\\s*" + /* 9 ?<hd> */
						   "<td[^>]*><a href=\"([^\"]*)\">Download", /* 10 ?<link> */
						   matches)) { 

			if(string(matches[2]["first"]) == episodeNumber) {
				dictionary item;
				item["id"] = string(matches[10]["first"]);
				item["title"] = "S0" + string(matches[1]["first"]) + "E0" + string(matches[2]["first"]) + " " + HostUrlDecode(string(matches[3]["first"])) + " " + string(matches[5]["first"]);
				item["lang"] = string(matches[4]["first"]);
				item["format"] = "srt";
				ret.insertLast(item);
			}
		}	
	}
	return ret;
}
 
string SubtitleDownload(string url) {
	return FetchData(url);
}

string getShowId(string name) {
	string data = FetchData("/search.php?Submit=Search&search=" + name);
	data = data.substr(0, data.find('id="footermenu"'));
	
	if(data.find("/show/") > 0) {
		return formatUInt(parseUInt(data.substr(data.find("/show/")+6)));
	}
	
	if(data.find("href=\"serie/") > 0) {
		int b = data.find("href=\"serie/") + 6;
		int e = data.find("\"",b);
		string data2 = FetchData(data.substr(b, e-b));
		if(data2.find("/show/") > 0) {
			return formatUInt(parseUInt(data2.substr(data2.find("/show/")+6)));
		}		
	}

	return "";
}

string FetchData(string url) {
	return HostUrlGetString(API_URL + url, UserAgent, Header, "", cookie);
}

