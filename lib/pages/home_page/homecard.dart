import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/details_page.dart';
import 'package:palette_generator/palette_generator.dart';

class HomeCard extends StatefulWidget {
  final String img;
  final String url;
  final String title;
  final String subtext;
  final PaletteGenerator palette;
  final double width;
  final Function(VoidCallback fn) setState;

  const HomeCard(
      {Key? key,
      required this.img,
      required this.title,
      this.subtext = "",
      required this.palette,
      required this.width,
      required this.url,
      required this.setState})
      : super(key: key);

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double imageHeight = 130;
    Color backgroundColor;
    PaletteColor? colorset =
        isDark ? widget.palette.vibrantColor : widget.palette.lightVibrantColor;
    if (colorset == null) {
      backgroundColor =
          isDark ? Colors.blueGrey : Colors.lightBlueAccent.shade100;
    } else {
      backgroundColor = colorset.color;
    }
    Color textColor = isDark ? Colors.white : Colors.black;

    return Stack(alignment: Alignment.topRight, children: [
      Container(
          width: widget.width.toDouble(),
          padding: EdgeInsets.all(8.0),
          child: Material(
              child: InkWell(
                  splashColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  highlightColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => DetailsPage(
                            title: widget.title,
                            url: widget.url,
                            homeCard: widget)));
                    setState(() {});
                  },
                  onLongPress: () {
                    showInfo(
                        context: context,
                        setState: widget.setState,
                        image: widget.img,
                        name: widget.title,
                        url: widget.url);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              backgroundColor.withOpacity(isDark ? 0.2 : 0.3)),
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(widget.img,
                                    fit: BoxFit.cover,
                                    height: imageHeight,
                                    width: imageHeight * 2 / 3)),
                            Padding(padding: EdgeInsets.all(8)),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(widget.title.replaceAll(" (Dub)", ""),
                                      maxLines: 4,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor)),
                                  if (widget.subtext.isNotEmpty)
                                    Padding(padding: EdgeInsets.all(2)),
                                  if (widget.subtext.isNotEmpty)
                                    Text(widget.subtext,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: textColor.withOpacity(0.8)))
                                ]))
                          ])))))),
      if (widget.title.endsWith(" (Dub)"))
        Positioned(
            top: 5,
            right: 5,
            child: Tooltip(
                message: "Dubbed",
                child: Container(
                    decoration: BoxDecoration(
                        color: backgroundColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.language))))
    ]);
  }
}