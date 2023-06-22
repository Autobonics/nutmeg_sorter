import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'startup_viewmodel.dart';

class StartupView extends StatelessWidget {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartupViewModel>.nonReactive(
      viewModelBuilder: () => StartupViewModel(),
      onModelReady: (model) => model.handleStartupLogic(),
      builder: (context, model, child) => Scaffold(
        // backgroundColor: kPrimaryColor,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/splash.png',
                height: 250,
              )
            ],
          ),
        ),
      ),
    );
  }
}
