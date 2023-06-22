import 'package:flutter/material.dart';
import 'package:ring_sorting_flutter/models/models.dart';
import 'package:ring_sorting_flutter/ui/smart_widgets/online_status.dart';
import 'package:stacked/stacked.dart';

import 'control_viewmodel.dart';

class ControlView extends StatelessWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ControlViewModel>.reactive(
      onViewModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        // print(model.node?.lastSeen);
        return Scaffold(
            appBar: AppBar(
              title: const Text('Manual control'),
              centerTitle: true,
              actions: [IsOnlineWidget()],
            ),
            body: model.node != null ? const _HomeBody() : Text("No data"));
      },
      viewModelBuilder: () => ControlViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<ControlViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, ControlViewModel model) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // if(model.node!=null)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _Indicator(
              text: model.node!.isIr ? "Nutmeg detected" : "No Nutmeg",
              icon: model.node!.isIr
                  ? Icons.light_mode
                  : Icons.light_mode_outlined,
              isTrue: model.node!.isIr,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _OtherButtons(
                  text1: "Rotate hopper",
                  text2: "Stop hopper rotation",
                  icon1: Icons.play_circle,
                  icon2: Icons.stop_circle,
                  isTrue: !model.deviceData.stepper1,
                  onTap: model.setStepper1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _OtherButtons(
                  text1: "Rotate conveyor 1",
                  text2: "Stop conveyor 1 rotation",
                  icon1: Icons.play_circle,
                  icon2: Icons.stop_circle,
                  isTrue: !model.deviceData.stepper2,
                  onTap: model.setStepper2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _OtherButtons(
                  text1: "Rotate conveyor 2",
                  text2: "Stop conveyor 2 rotation",
                  icon1: Icons.play_circle,
                  icon2: Icons.stop_circle,
                  isTrue: !model.deviceData.stepper3,
                  onTap: model.setStepper3,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _OtherButtons(
                  text1: "Left direction",
                  text2: "Right direction",
                  icon1: Icons.turn_left,
                  icon2: Icons.turn_right,
                  isTrue: model.deviceData.servoAngle == servoCloseC,
                  onTap: model.deviceData.servoAngle == servoCloseC
                      ? model.leftDirection
                      : model.rightDirection,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicator extends ViewModelWidget<ControlViewModel> {
  final String text;
  final IconData icon;
  final bool isTrue;
  const _Indicator({
    required this.text,
    required this.icon,
    required this.isTrue,
    Key? key,
  }) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, ControlViewModel model) {
    Widget _buildThermometer(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isTrue ? Colors.red : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 0.0,
              ),
            ],
          ),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(text), Icon(icon)],
              ),
            ),
          ),
        ),
      );
    }

    return _buildThermometer(context);
  }
}

class _OtherButtons extends ViewModelWidget<ControlViewModel> {
  final String text1;
  final String text2;
  final IconData icon1;
  final IconData icon2;
  final bool isTrue;
  final VoidCallback onTap;
  const _OtherButtons({
    required this.text1,
    required this.text2,
    required this.icon1,
    required this.icon2,
    required this.isTrue,
    required this.onTap,
    Key? key,
  }) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, ControlViewModel model) {
    Widget _buildThermometer(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isTrue ? Colors.teal : Colors.teal,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isTrue ? text1 : text2),
                    Icon(isTrue ? icon1 : icon2)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _buildThermometer(context);
  }
}

// class _ConditionButton extends ViewModelWidget<ControlViewModel> {
//   final String text;
//   final bool isTrue;
//   final VoidCallback onTap;
//   const _ConditionButton({
//     required this.text,
//     required this.isTrue,
//     required this.onTap,
//     Key? key,
//   }) : super(key: key, reactive: true);
//
//   @override
//   Widget build(BuildContext context, ControlViewModel model) {
//     Widget _buildThermometer(BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: isTrue ? Colors.teal : Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(0.0, 1.0), //(x,y)
//                 blurRadius: 6.0,
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: onTap,
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Text(text),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return _buildThermometer(context);
//   }
// }
