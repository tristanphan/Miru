import 'dart:async';

import 'package:miru/data/structures/video_details.dart';
import 'package:web_scraper/web_scraper.dart';

Completer<String> errorVideoUrl = Completer<String>();

Future<VideoDetails?> getVideo(String url, Function changeProgress) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  errorVideoUrl = Completer<String>();

  print("Getting Video URL: " + url);

  changeProgress("Loading Episode URL");
  WebScraper web = WebScraper("https://gogoanime.vc/");
  await web.loadFullURL(url);

  String title = web.getElementTitle('div.title_name > h2')[0].trim();

  // Get Last Episode
  List<String> lastEpisode = [];
  if (web.getElementTitle('div.anime_video_body_episodes_l > a').length == 1) {
    String lastName =
        web.getElementTitle('div.anime_video_body_episodes_l > a')[0].trim();
    String lastURL = "https://gogoanime.vc" +
        web
            .getElementAttribute(
                'div.anime_video_body_episodes_l > a', 'href')[0]!
            .trim();
    lastEpisode.add(lastName.substring(3));
    lastEpisode.add(lastURL);
  }

  // Get Next Episode
  List<String> nextEpisode = [];
  if (web.getElementTitle('div.anime_video_body_episodes_r > a').length == 1) {
    String nextName =
        web.getElementTitle('div.anime_video_body_episodes_r > a')[0].trim();
    String nextURL = "https://gogoanime.vc" +
        web
            .getElementAttribute(
                'div.anime_video_body_episodes_r > a', 'href')[0]!
            .trim();
    nextEpisode.add(nextName.substring(0, nextName.length - 3));
    nextEpisode.add(nextURL);
  }

  // Get URL of iframe and load it
  String? frameURL =
      web.getElementAttribute('div.play-video > iframe', 'src')[0];
  if (frameURL == null) return null;

  frameURL = "http:" + frameURL.replaceAll("streaming", "loadserver");
  changeProgress("Loading Video Player URL");
  errorVideoUrl.complete(frameURL);
  await web.loadFullURL(frameURL);

  String videoURL;
  try {
    videoURL = web.getPageContent();
    videoURL = videoURL.split("sources:[{file: '")[1];
    videoURL = videoURL.split("',")[0];
    changeProgress("Preparing Video Player");
    print("Video URL: " + videoURL);
    if (!videoURL.startsWith("ht")) return null;
  } catch (error) {
    return null;
  }

  print("Video Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  return VideoDetails(
      title: title, url: videoURL, next: nextEpisode, last: lastEpisode);
}