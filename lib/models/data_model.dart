// Data model to store all the strings
class DataModel {
  static const approveProducts = "Approve Products";
  static const noPendingProducts = "No Pending Products";
  static const pleaseWait = "Please wait";
  static const total = " Total: ";
  static const placeOrder = "PLACE ORDER";
  static const defaultImageUrl =
      "https://bitsofco.de/content/images/2018/12/broken-1.png";

  //  Errors
  static const pleaseSelectImageError =
      "Please select an image from camera/gallery";
  static const provideProductNameError = "Please provide a product name";
  static const productNameMinLengthError =
      "Product name should be > 3 characters";
  static const productNameMaxLengthError =
      "Product name should be < 25 characters";
  static const providePriceError = "Please provide price";
  static const provideValidPriceError = "Please provide a valid price";
  static const providePositivePriceError = "Please provide a price > 0";
  static const provideDescriptionError = "Please provide product description";
  static const descriptionMinLengthError =
      "Description should be > 15 characters";
  static const connectToInternetWarningForChanges =
      "Please connect to internet.\nChanges will be reflected after internet connection is regained";
  static const connectToInternetWarningForProducts =
      "Please connect to internet.\nProducts will be visible after internet connection is regained";
  static const somethingWentWrong =
      "Something went wrong\n Please try again later.";
  static const noUpiAppError = "Sorry, no UPI apps installed";

  static const addProduct = "Add Product";
  static const editProduct = "Edit Product";
  static const productName = "Product name";
  static const productPriceRs = "Product price (Rs.)";
  static const productDescription = "Product description";
  static const productCategory = "Product Category:";
  static const submit = "Submit";
  static const kiranaMartTwoLined = "Kirana\nMart";
  static const home = "Home";
  static const fav = "Fav";
  static const loadingProducts = "Loading products";

  //  Login and signup
  static const signup = "Sign Up ?";
  static const welcomeBack = "Welcome Back!";
  static const howdyAuthenticate = "Howdy, let's authenticate";
  static const email = "E-Mail";
  static const invalidEmail = "Invalid email!";
  static const password = "Password";
  static const passwordMinLengthLimitError =
      "Password must be atleast 6 characters long!";
  static const forgotPassword = "Forgot Password ?";

  //  Verify email
  static const verifyMailToSell =
      "Please verify email to\nstart selling products";
  static const verifyMailToOrder = "Please verify email to place order";

  static const validUpiToSell =
      "Valid Upi id must be provided to start selling";

  static const productsVisibleAfterVerificationAdmin =
      "New products/edits are visible after admin approval";

  static const noNotifications = "No notifications for you now";

  static const myCart = "My Cart";
  static const myProducts = "My Products";
  static const myOrders = "My Orders";
  static const myNotifications = "My Notifications";

  static const cod = "COD";
  static const upi = "UPI";
  static const confirmPurchase = "Confirm purchase";
  static const payment = "Payment";
  static const cash = "Cash";
}
