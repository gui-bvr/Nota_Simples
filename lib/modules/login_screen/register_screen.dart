import '../../routes/app_imports.dart';
import 'package:sizer/sizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool _isObscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: primaryBackground,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registrar',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 45),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryGreyColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Ionicons.at),
                          border: InputBorder.none,
                          hintText: 'Digite seu email',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 45),
                    Text(
                      'Senha',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryGreyColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: _isObscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Ionicons.lock_closed_outline),
                          border: InputBorder.none,
                          hintText: 'Digite sua senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscurePassword
                                  ? Ionicons.eye_outline
                                  : Ionicons.eye_off_outline,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscurePassword = !_isObscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(width: 28),
                SizedBox(height: 3.h),
                GestureDetector(
                  onTap: () {
                    AuthController.authInstance.register(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'REGISTRAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voltar para o ',
                      style: TextStyle(
                        color: primaryGreyColor,
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
