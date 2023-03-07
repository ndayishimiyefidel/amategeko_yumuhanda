import '../utils/constants.dart';
import 'package:flutter/material.dart';
import '../resources/user_state_methods.dart';


class CommonAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final menuenabled;
  final bool notificationenabled;
  final Function ontap;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.menuenabled,
    required this.notificationenabled,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.25,
          fontSize: 24,
        ),
      ),
      leading: menuenabled == true
          ? IconButton(
              color: Colors.white,
              onPressed: ontap(),
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            )
          : IconButton(
              color: Colors.white,
              onPressed: ontap(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
      actions: [
        notificationenabled == true
            ? InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 25,
                  ),
                ),
              )
            : InkWell(
                onTap: () => UserStateMethods().logoutuser(context),
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    size: 25,
                  ),
                ),
              ),
      ],
      centerTitle: true,
      backgroundColor: kPrimaryColor,
      elevation: 0.0,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}
