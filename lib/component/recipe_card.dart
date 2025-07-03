import 'package:flutter/material.dart';
import 'package:recipe_app/model/recipe_model.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:recipe_app/page/recipe_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipeData;
  const RecipeCard({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetailPage(
                      recipeData: recipeData,
                    )));
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 30),
          height: 200,
          child: Container(
            // height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.amber,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 204, 195, 195),
                  offset: Offset(0.0, 1.0),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: recipeData.image,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                    // height: 100,
                  ),
                ),

                // Image.network(
                //   recipeData.image,
                //   fit: BoxFit.cover,
                //   // height: 50,
                //   width: double.infinity,
                // ),
                Positioned(
                    // bottom: 0,
                    // width: double.infinity,
                    child: BlurryContainer(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.2),
                        blur: 1.1,
                        child: Center(
                            child: Text(
                          recipeData.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.03,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )))),
              ],
            ),
          )),
    );
  }
}
