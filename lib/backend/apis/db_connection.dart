class API {
  // App Configuration
  static const appUpdateUrl =
      'https://play.google.com/store/apps/details?id=com.rwanda.trafficrules';
  static const baseUrl = 'https://rwandatraffic.rw';
  static const app_version_url = '$baseUrl/app_version.json';
  static const hostUser = "$baseUrl/user";

  // ========================================
  // AUTHENTICATION & USER MANAGEMENT APIs
  // ========================================
  static const validate = "$hostUser/validate.php";
  static const signUp = "$hostUser/signup.php";
  static const iyandikishe = "$hostUser/iyandikishe.php";
  static const login = "$hostUser/login.php";
  static const updateProfile = "$hostUser/updateProfile.php";
  static const getToken = "$hostUser/getToken.php";
  static const updateFcmToken = "$hostUser/updateFcm.php";

  // ========================================
  // CODE MANAGEMENT APIs
  // ========================================
  static const checkCode = "$hostUser/checkCode.php";
  static const navigateToIshuri = "$hostUser/navigateToIshuri.php";
  static const requestCode = "$hostUser/requestCode.php";
  static const sabaCode = "$hostUser/sabaCode.php";
  static const generatecode = "$hostUser/generateCode.php";
  static const deleteCode = "$hostUser/deleteCode.php";
  static const setLimitTime = "$hostUser/setLimitTime.php";

  // ========================================
  // QUIZ MANAGEMENT APIs
  // ========================================
  static const isQuizOpen = "$hostUser/isQuizOpen.php";
  static const isEngQuizOpen = "$hostUser/isEngQuizOpen.php";
  static const fetchQuizData = "$hostUser/searchingCodes.php";
  static const fetchById = "$hostUser/displayUserCode.php";
  static const fetchAbafiteCode = "$hostUser/fetchAbafiteCode.php";
  static const fetchAbadafiteCode = "$hostUser/fetchAbadafiteCode.php";
  static const createCourseQuiz = "$hostUser/createCourseQuiz.php";
  static const getCourseQuiz = "$hostUser/getCourseQuiz.php";
  static const deleteQuestion = "$hostUser/deleteQuestion.php";
  static const updateCourseQuestion = "$hostUser/updateCourseQuestion.php";

  // ========================================
  // USER MANAGEMENT APIs
  // ========================================
  static const deleteUser = "$hostUser/deleteUser.php";
  static const deleteSingleUser = "$hostUser/deleteSingleUser.php";
  static const deleteIremboUser = "$hostUser/deleteIremboUser.php";
  static const searchUser = "$hostUser/searchUser.php";
  static const userWithCode = "$hostUser/userWithCode.php";
  static const userWithNoCode = "$hostUser/userWithNoCode.php";
  static const abiyandikishije = "$hostUser/abiyandikishije.php";
  static const notInIrembo = "$hostUser/notInIrembo.php";
  static const addedToClass = "$hostUser/addedToClass.php";
  static const updateOnlineSchoolAccess =
      "$hostUser/updateOnlineSchoolAccess.php";

  // ========================================
  // GROUP MANAGEMENT APIs
  // ========================================
  static const createGroup = "$hostUser/createGroup.php";
  static const fetchGroups = "$hostUser/fetchGroups.php";
  static const deletegroup = "$hostUser/deleteGroup.php";

  // ========================================
  // COURSE MANAGEMENT APIs
  // ========================================
  static const createCourse = "$hostUser/createCourse.php";
  static const deleteCourse = "$hostUser/deleteCourse.php";
  static const updateCourse = "$hostUser/updateCourse.php";
  static const courseList = "$hostUser/courseList.php";
  static const getCourseById = "$hostUser/getCourseById.php";
  static const duplicateCourse = "$hostUser/duplicateCourse.php";
  static const searchCourses = "$hostUser/searchCourses.php";
  static const getCourseAnalytics = "$hostUser/getCourseAnalytics.php";

  // ========================================
  // LESSON CONTENT MANAGEMENT APIs
  // ========================================
  static const uploadContent = "$hostUser/uploadContent.php";
  static const openCourseContent = "$hostUser/openCourseContent.php";
  static const deleteContent = "$hostUser/deleteContent.php";
  static const updateLessonContent = "$hostUser/updateLessonContent.php";
  static const getLessonById = "$hostUser/getLessonById.php";
  static const reorderLessons = "$hostUser/reorderLessons.php";
  static const duplicateLesson = "$hostUser/duplicateLesson.php";
  static const bulkDeleteLessons = "$hostUser/bulkDeleteLessons.php";
  static const searchLessons = "$hostUser/searchLessons.php";
  static const getLessonAnalytics = "$hostUser/getLessonAnalytics.php";

  // ========================================
  // MEDIA MANAGEMENT APIs
  // ========================================
  static const uploadMedia = "$hostUser/uploadMedia.php";
  static const deleteMedia = "$hostUser/deleteMedia.php";
  static const getMediaList = "$hostUser/getMediaList.php";
  static const updateMedia = "$hostUser/updateMedia.php";
  static const getMediaById = "$hostUser/getMediaById.php";

  // ========================================
  // AUDIO PLAYBACK TRACKING APIs
  // ========================================
  static const trackAudioPlay = "$hostUser/trackAudioPlay.php";
  static const getAudioProgress = "$hostUser/getAudioProgress.php";
  static const saveAudioProgress = "$hostUser/saveAudioProgress.php";
  static const getAudioAnalytics = "$hostUser/getAudioAnalytics.php";
  static const resetAudioProgress = "$hostUser/resetAudioProgress.php";

  // ========================================
  // LESSON VIEWS & ANALYTICS APIs
  // ========================================
  static const trackLessonView = "$hostUser/trackLessonView.php";
  static const getLessonViews = "$hostUser/getLessonViews.php";
  static const getCourseStats = "$hostUser/getCourseStats.php";
  static const getUserProgress = "$hostUser/getUserProgress.php";
  static const getLearningAnalytics = "$hostUser/getLearningAnalytics.php";

  // ========================================
  // COURSE ENROLLMENT & ACCESS APIs
  // ========================================
  static const enrollInCourse = "$hostUser/enrollInCourse.php";
  static const checkCourseAccess = "$hostUser/checkCourseAccess.php";
  static const getUserCourses = "$hostUser/getUserCourses.php";
  static const unenrollFromCourse = "$hostUser/unenrollFromCourse.php";
  static const updateEnrollmentProgress =
      "$hostUser/updateEnrollmentProgress.php";
  static const getEnrollmentStatus = "$hostUser/getEnrollmentStatus.php";

  // ========================================
  // NOTIFICATION & COMMUNICATION APIs
  // ========================================
  static const sendNotification = "$hostUser/sendNotification.php";
  static const getNotifications = "$hostUser/getNotifications.php";
  static const markNotificationRead = "$hostUser/markNotificationRead.php";
  static const deleteNotification = "$hostUser/deleteNotification.php";

  // ========================================
  // FILE UPLOAD PATHS
  // ========================================
  static const imageUploadPath = "$baseUrl/user/uploads/images/";
  static const audioUploadPath = "$baseUrl/user/uploads/audio/";
  static const documentUploadPath = "$baseUrl/user/uploads/documents/";
  static const videoUploadPath = "$baseUrl/user/uploads/videos/";

  // ========================================
  // UTILITY & SYSTEM APIs
  // ========================================
  static const systemHealth = "$hostUser/systemHealth.php";
  static const clearCache = "$hostUser/clearCache.php";
  static const exportData = "$hostUser/exportData.php";
  static const importData = "$hostUser/importData.php";
  static const backupDatabase = "$hostUser/backupDatabase.php";

  // Exam Results & Progress Tracking
  static const String getUserExamResults = "$hostUser/getUserExamResults.php";
  static const String saveExamResult = "$hostUser/saveExamResult.php";
  static const String getExamHistory = "$hostUser/getExamHistory.php";
}
