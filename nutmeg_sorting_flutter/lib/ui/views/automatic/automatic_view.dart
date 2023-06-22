import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ring_sorting_flutter/ui/smart_widgets/online_status.dart';
import 'package:stacked/stacked.dart';

import 'automatic_viewmodel.dart';

class AutomaticView extends StatelessWidget {
  const AutomaticView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TrainViewModel>.reactive(
      onViewModelReady: (model) => model.onModelReady(),
      builder: (context, model, child) {
        // print(model.node?.lastSeen);
        return Scaffold(
            appBar: AppBar(
              title: const Text('Automatic sorting'),
              centerTitle: true,
              actions: [IsOnlineWidget()],
            ),
            body: model.node != null ? const _HomeBody() : Text("No data"));
      },
      viewModelBuilder: () => TrainViewModel(),
    );
  }
}

class _HomeBody extends ViewModelWidget<TrainViewModel> {
  const _HomeBody({Key? key}) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, TrainViewModel model) {
    void _showBottomSheet(BuildContext context) async {
      final String? result = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return MyBottomSheet(delayTime: model.deviceData.timeDelay);
        },
      );

      if (result != null) {
        model.setDelayTime(int.parse(result));
      } else {
        print("No data");
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // if(model.node!=null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _OtherButtons(
                            text1: "Start sorting",
                            text2: "Stop sorting",
                            icon1: Icons.play_circle,
                            icon2: Icons.stop_circle,
                            isTrue: !model.isSorting,
                            onTap: model.isSorting
                                ? model.stopSorting
                                : model.sort,
                            isLoading: !model.isSorting && model.isNutPlaced,
                          ),
                          if (!model.isSorting)
                            _NormalButton(
                              text: "Edit delay time",
                              icon: Icons.timer,
                              onTap: () {
                                _showBottomSheet(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (model.isBusy || !model.controller.value.isInitialized)
                  Container()
                else
                  CameraPreview(model.controller),
              ],
            ),
          ),
        ),
        if (model.topImg != null)
          Positioned(
            bottom: 0,
            child: ImageViewer(img: model.topImg!),
          ),
      ],
    );
  }
}

class ImageViewer extends StatelessWidget {
  final File img;
  const ImageViewer({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        height: MediaQuery.of(context).size.height * 0.3,
        // width: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey,
          //     offset: Offset(0.0, 1.0), //(x,y)
          //     blurRadius: 6.0,
          //   ),
          // ],
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                img,
                // fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherButtons extends ViewModelWidget<TrainViewModel> {
  final String text1;
  final String text2;
  final IconData icon1;
  final IconData icon2;
  final bool isTrue;
  final bool isLoading;
  final VoidCallback onTap;
  const _OtherButtons({
    required this.text1,
    required this.text2,
    required this.icon1,
    required this.icon2,
    required this.isTrue,
    required this.onTap,
    required this.isLoading,
    Key? key,
  }) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, TrainViewModel model) {
    Widget _buildThermometer(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isLoading ? Colors.teal.withOpacity(.5) : Colors.teal,
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
              onTap: !isLoading ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isLoading
                        ? "Stopping..."
                        : isTrue
                            ? text1
                            : text2),
                    isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ))
                        : Icon(isTrue ? icon1 : icon2)
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

class _NormalButton extends ViewModelWidget<TrainViewModel> {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _NormalButton({
    required this.text,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, TrainViewModel model) {
    Widget _buildThermometer(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.teal,
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
                  children: [Text(text), Icon(icon)],
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

class MyBottomSheet extends StatefulWidget {
  final int delayTime;
  MyBottomSheet({Key? key, required this.delayTime}) : super(key: key);

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _textEditingController.text = widget.delayTime.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: TextField(
                autofocus: true,
                controller: _textEditingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter delay time in seconds',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                final text = _textEditingController.text.trim();
                if (text.isNotEmpty) {
                  // widget.onSubmitted(text);
                  Navigator.pop(context, text);
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
