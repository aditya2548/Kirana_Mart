import 'dart:io';

import '../dialog/custom_dialog.dart';
import 'package:delayed_display/delayed_display.dart';

import '../models/product.dart';
import '../models/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//  Screen to edit existing/ add new products into the list of products provided by user
class EditUserProductScreen extends StatefulWidget {
  static const routeName = "/edit_user_product_screen";
  @override
  _EditUserProductScreenState createState() => _EditUserProductScreenState();
}

class _EditUserProductScreenState extends State<EditUserProductScreen> {
  static const CAMERA_REQUEST_CODE = 1000;
  static const GALLERY_REQUEST_CODE = 1001;
  //  variable to show loading when product is being saved
  bool _progressBar = false;

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  File _image;
  //  form key(used to save product)
  final _formKey = GlobalKey<FormState>();

  //  Product object used to store the object
  var _editedProduct = Product(
      id: null,
      title: "",
      description: "",
      imageUrl: "https://bitsofco.de/content/images/2018/12/broken-1.png",
      price: 0,
      productCategory: ProductCategory.HouseHold);

  //  Need to dispose focusNode otherwise they may lead to memory leaks
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  //  ModalRoute doesn't work in initState, so using here
  //  isInit is used so that this runs only once when screen initiated
  //  whereas didChangeDependencies runs multiple times
  var _init = true;
  String _productId = "";

  //  To store the initial values of fields
  var _initialProductCategory =
      Product.productCattoString(ProductCategory.HouseHold);
  var _initialTitle = "";
  var _initialPrice = "";
  var _initialDescription = "";
  var _initialImageUrl =
      "https://bitsofco.de/content/images/2018/12/broken-1.png";

  @override
  void didChangeDependencies() {
    if (_init) {
      _productId = ModalRoute.of(context).settings.arguments;
      if (_productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .getProductFromId(_productId);
        _initialTitle = _editedProduct.title;
        _initialDescription = _editedProduct.description;
        _initialPrice = _editedProduct.price.toString();
        _initialProductCategory =
            Product.productCattoString(_editedProduct.productCategory);
        _initialImageUrl = _editedProduct.imageUrl;
      }
    }

    //  Changed to false so that this code doesn't run many times
    _init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //  Function to pickup an image from camera or gallery
    //  And update the image icon
    Future getImage(int reqCode) async {
      final ip = ImagePicker();
      PickedFile image;
      if (reqCode == CAMERA_REQUEST_CODE) {
        image = await ip.getImage(source: ImageSource.camera);
      } else {
        image = await ip.getImage(source: ImageSource.gallery);
      }
      setState(() {
        _image = File(image.path);
      });
    }

    //  Function to save product and exit screen if valid product
    Future<void> saveProduct() async {
      //  trigger validators
      final isValid = _formKey.currentState.validate();
      if (isValid) {
        //  trigger onSaved
        _formKey.currentState.save();
        setState(() {
          //  Start showing progress bar
          _progressBar = true;
        });

        //  If updating existing product
        if (_editedProduct.id != null) {
          Provider.of<ProductsProvider>(context, listen: false)
              .updateProduct(_editedProduct.id, _editedProduct);
          setState(() {
            //  Stop showing progress bar
            _progressBar = false;
          });
          Navigator.of(context).pop();
        }
        //  if adding new product
        else {
          try {
            await Provider.of<ProductsProvider>(context, listen: false)
                .addProduct(_editedProduct);
          } catch (error) {
            CustomDialog.generalErrorDialog(context);
          } finally {
            setState(() {
              //  Stop showing progress bar
              _progressBar = false;
            });
            Navigator.of(context).pop();
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_productId == null ? "Add product" : "Edit product"),
        actions: [
          IconButton(icon: Icon(Icons.save_rounded), onPressed: saveProduct)
        ],
      ),
      body: _progressBar == true
          ?
          //  visible when saving product
          Center(
              child: Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressIndicator(),
                    Text("Please wait"),
                    DelayedDisplay(
                        delay: Duration(seconds: 5),
                        child: Text(
                          "Please connect to internet.\nChanges will be reflected after internet connection is regained",
                          style: TextStyle(fontSize: 7),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
            )
          //  Main body
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: Form(
                  //  Used SingleChildScrollView with column instead of listview
                  //  as listview dynamically removes and re-adds widget
                  //  So we might loose data if say, we are in landscape mode
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initialTitle,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(fontSize: 10),
                        decoration: InputDecoration(
                            labelText: "Product name",
                            errorStyle: TextStyle(fontSize: 8)),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        onSaved: (title) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: title,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          productCategory: _editedProduct.productCategory,
                          isFav: _editedProduct.isFav,
                        ),
                        //  null returned in validator->input is correct
                        validator: (title) {
                          if (title == null || title.trim() == "") {
                            return "Please provide a product name";
                          } else if (title.length < 3) {
                            return "Product name should be > 3 characters";
                          } else if (title.length > 25) {
                            return "Product name should be < 25 characters";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initialPrice,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        focusNode: _priceFocusNode,
                        style: TextStyle(fontSize: 10),
                        decoration: InputDecoration(
                            labelText: "Product price (Rs.)",
                            errorStyle: TextStyle(fontSize: 10)),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                        onSaved: (price) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          price: double.parse(price),
                          productCategory: _editedProduct.productCategory,
                          isFav: _editedProduct.isFav,
                        ),
                        validator: (price) {
                          if (price == null || price.trim() == "") {
                            return "Please provide price";
                          } else if (double.tryParse(price) == null) {
                            return "Please provide a valid price";
                          } else if (double.parse(price) <= 0) {
                            return "Please provide a price > 0";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initialDescription,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        focusNode: _descriptionFocusNode,
                        style: TextStyle(fontSize: 10),
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                            labelText: "Product description",
                            errorStyle: TextStyle(fontSize: 10)),
                        keyboardType: TextInputType.multiline,
                        onSaved: (desc) => _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: desc,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                          productCategory: _editedProduct.productCategory,
                          isFav: _editedProduct.isFav,
                        ),
                        validator: (desc) {
                          if (desc == null || desc.trim() == "") {
                            return "Please provide product description";
                          } else if (desc.length <= 15) {
                            return "Description should be > 15 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Product Category:",
                            style: TextStyle(fontSize: 10),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          DropdownButton<String>(
                            items: ProductCategory.values
                                .map((e) => DropdownMenuItem<String>(
                                    value: Product.productCattoString(e),
                                    child: Text(
                                      Product.productCattoString(e),
                                      style: TextStyle(fontSize: 10),
                                    )))
                                .toList(),
                            onChanged: (selected) {
                              //  This line added to stop focus from going back to last textformfield
                              FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {
                                _initialProductCategory = selected;
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  imageUrl: _editedProduct.imageUrl,
                                  price: _editedProduct.price,
                                  productCategory:
                                      Product.stringtoProductCat(selected),
                                  isFav: _editedProduct.isFav,
                                );
                              });
                            },
                            value: _initialProductCategory,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: _image != null
                                ? Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    _initialImageUrl,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera,
                              size: 30,
                            ),
                            onPressed: () => getImage(CAMERA_REQUEST_CODE),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.insert_photo,
                              size: 30,
                            ),
                            onPressed: () => getImage(GALLERY_REQUEST_CODE),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(5),
                        child: Text("Submit"),
                        onPressed: saveProduct,
                      )
                    ],
                  ))),
            ),
    );
  }
}
