// ignore_for_file: prefer_const_constructors, sort_child_properties_last

part of 'widgets.dart';

class SwipeCardsWidget extends StatefulWidget {
  SwipeCardsWidget({Key? key}) : super(key: key);
  @override
  State<SwipeCardsWidget> createState() => _SwipeCardsWidgetState();
}

class _SwipeCardsWidgetState extends State<SwipeCardsWidget> {
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<String> images = [];
  late AnimationController controller;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  late MealClass currentMeal;
  void loadData() async {
    isLoading = true;
    await loadSwipeCardContent();
    currentIndex = 0;
    currentMeal = allMeal[currentIndex];
    for (int i = currentIndex; i < allMeal.length; i++) {
      _swipeItems.add(SwipeItem(
          content: Content(text: allMeal[i].name),
          likeAction: () {
            // _scaffoldKey.currentState?.showSnackBar(SnackBar(
            //   content: Text("Liked ${_names[i]}"),
            //   duration: Duration(milliseconds: 500),
            // ));
            currentIndex = i + 1;
            print("before");
            print(currentUser!.likes.length);
            firestore.collection('users').doc(currentUser!.id).update({
              "likes": FieldValue.arrayUnion([allMeal[i].id]),
            });
            likedMeal.add(allMeal[i]);

            reloadUserData();
            print("after");
            print(currentUser!.likes.length);
          },
          nopeAction: () {
            // _scaffoldKey.currentState?.showSnackBar(SnackBar(
            //   content: Text("Nope ${_namesR[i]}"),
            //   duration: Duration(milliseconds: 500),
            // ));
            currentIndex = i + 1;
            print("Nope ${allMeal[i].name}");
            firestore.collection('users').doc(currentUser!.id).update({
              "dislikes": FieldValue.arrayUnion([allMeal[i].id]),
            });
            dislikedMeal.add(allMeal[i]);

            reloadUserData();
          },
          // superlikeAction: () {
          //   // _scaffoldKey.currentState?.showSnackBar(SnackBar(
          //   //   content: Text("Superliked ${_names[i]}"),
          //   //   duration: Duration(milliseconds: 500),
          //   // ));
          //   firestore.collection('users').doc(currentUser!.id).update({
          //     "likes": FieldValue.arrayUnion([data![i].id]),
          //   });
          //   print("Superliked ${data![i].name}");
          //   currentIndex = i + 1;
          // },
          onSlideUpdate: (SlideRegion? region) async {
            // print("Region $region");
          }));
      print("CARD ADDED");
      images.add(allMeal[i].imageUrl);
    }
    setState(() {}); // refresh

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    print(_matchEngine);
    isLoading = false;
  }

  @override
  void initState() {
    loadData();
    super.initState();

    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 5),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return (!isLoading && _swipeItems.length > 0)
        ? Column(children: [
            Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                          children: [
                            Container(
                                child: _matchEngine != null
                                    ? GestureDetector(
                                        onTap: () {
                                          print("Next page");
                                          Navigator.pushNamed(
                                              context, '/meal_details',
                                              arguments: currentMeal);
                                        },
                                        child: SwipeCards(
                                          matchEngine: _matchEngine!,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              alignment: Alignment.bottomLeft,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        images[index]),
                                                    fit: BoxFit.cover),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(30.0),
                                                  bottomRight:
                                                      Radius.circular(30.0),
                                                ),
                                              ),
                                              child: Text(
                                                _swipeItems[index].content.text,
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      offset: Offset(0.0, 0.0),
                                                      blurRadius: 10.0,
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          onStackFinished: () {
                                            // _scaffoldKey.currentState.showSnackBar(SnackBar(
                                            //   content: Text("Stack Finished"),
                                            //   duration: Duration(milliseconds: 500),
                                            // ));
                                            print("Stack finish");
                                          },
                                          itemChanged:
                                              (SwipeItem item, int index) {
                                            print(
                                                "item: ${item.content.text}, index: $index");
                                            print(currentUser!.likes.length);
                                            currentMeal = allMeal[index];
                                          },
                                          upSwipeAllowed: false,
                                          fillSpace: true,
                                        ),
                                      )
                                    : SizedBox()),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          _matchEngine!.currentItem?.nope();
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.grey),
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Color.fromARGB(39, 255, 255, 255),
                                          shape: CircleBorder(),
                                          side: BorderSide(
                                              width: 3.0, color: Colors.grey),
                                          padding: EdgeInsets.all(
                                              20), // <-- Button color
                                          onPrimary: Color.fromARGB(255, 225,
                                              225, 225), // <-- Splash color
                                        )),
                                    ElevatedButton(
                                        onPressed: () {
                                          _matchEngine!.currentItem?.like();
                                        },
                                        child: Icon(Icons.favorite,
                                            color: Colors.pink),
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Color.fromARGB(39, 255, 255, 255),
                                          shape: CircleBorder(),
                                          side: BorderSide(
                                              width: 3.0, color: Colors.pink),
                                          padding: EdgeInsets.all(
                                              20), // <-- Button color
                                          onPrimary: Color.fromARGB(255, 225,
                                              225, 225), // <-- Splash color
                                        )),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                ),
                              ),
                            ),
                          ],
                        ))),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton(
            //         onPressed: () {
            //           _matchEngine!.currentItem?.nope();
            //         },
            //         child: Text("Nope")),
            //     // ElevatedButton(
            //     //     onPressed: () {
            //     //       _matchEngine!.currentItem?.superLike();
            //     //     },
            //     //     child: Text("Superlike")),
            //     ElevatedButton(
            //         onPressed: () {
            //           _matchEngine!.currentItem?.like();
            //         },
            //         child: Text("Like"))
            //   ],
            // )
          ])
        : SizedBox(
            height: 1,
            width: 10,
            child: Transform.scale(
              scale: 0.1,
              child: CircularProgressIndicator(
                strokeWidth: 40,
              ),
            ));
  }
}
