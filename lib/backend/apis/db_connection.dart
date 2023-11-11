class API {
  static const baseUrl = 'http://192.168.1.66/apis';
  static const hostUser = "$baseUrl/user";

  static const validate = "$hostUser/validate.php";

  //sign up
  static const signUp = "$hostUser/signup.php";
  static const login = "$hostUser/login.php";
  static const updateProfile = "$hostUser/updateProfile.php";
  static const getToken = "$hostUser/getToken.php";
  static const checkCode = "$hostUser/checkCode.php";
  static const requestCode = "$hostUser/requestCode.php";
  static const sabaCode = "$hostUser/sabaCode.php";
  static const isQuizOpen = "$hostUser/isQuizOpen.php";
  static const fetchQuizData = "$hostUser/searchingCodes.php";
  static const fetchById = "$hostUser/displayUserCode.php";
  static const fetchAbafiteCode = "$hostUser/fetchAbafiteCode.php";
  static const fetchAbadafiteCode = "$hostUser/fetchAbadafiteCode.php";
  static const generatecode = "$hostUser/generateCode.php";
  static const deleteCode = "$hostUser/deleteCode.php";
  static const deleteUser = "$hostUser/deleteUser.php";
  static const setLimitTime = "$hostUser/setLimitTime.php";
  static const addedToClass = "$hostUser/addedToClass.php";

  static const searchUser = "$hostUser/searchUser.php";
  static const userWithCode = "$hostUser/userWithCode.php";
  static const userWithNoCode = "$hostUser/userWithNoCode.php";
  //addedToClass
}