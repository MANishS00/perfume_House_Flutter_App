import 'package:flutter/material.dart';
import 'package:perfumeapp/constants/app_Button.dart';
import 'package:perfumeapp/constants/app_Text.dart';
import 'package:perfumeapp/constants/app_TextField.dart';
import 'package:perfumeapp/constants/app_ToastMessage.dart';
import 'package:perfumeapp/constants/app_colors.dart';
import 'package:perfumeapp/constants/card_Container.dart';
import 'package:perfumeapp/constants/gap_Extension.dart';
import '../services/api_service.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  bool loading = true;

  Map<String, String> tpl = {};

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    setState(() => loading = true);
    try {
      final res = await ApiService.getSiteTemplates();
      if (res['success'] == true) {
        final raw = res['templates'] as Map<String, dynamic>? ?? {};
        setState(
          () => tpl = raw.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        );
      } else {
        showAppToast(
          context,
          message: "Facing Technical Issue ",
          type: ToastType.error,
        );
      }
    } catch (e) {
      showAppToast(context, message: e.toString(), type: ToastType.error);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactEmail = tpl['site.contact.email'] ?? '';
    final contactPhone = tpl['site.contact.phone'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppText(text: 'Contact Us', size: 20, weight: FontWeight.w600),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Email Row
                    Row(
                      children: [
                        AppText(
                          text: 'Email Us : ',
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                        AppText(
                          text:
                              '${contactEmail.isNotEmpty ? contactEmail : 'Loading...'}',
                          size: 16,
                          color: AppColors.secondary,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    16.gap,

                    /// Subject
                    AppTextField(hintText: 'Enter subject here'),
                    16.gap,

                    /// Body
                    SizedBox(
                      height: 200,
                      child: AppTextField(
                        hintText: 'Enter your message here',
                        maxLines: 5,
                      ),
                    ),
                    16.gap,

                    /// Attachment
                    Row(
                      children: [
                        AppText(text: 'Attached: ', size: 16),
                        TextButton(
                          child: const Text("Select the File"),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    24.gap,

                    AppButton(text: "Send Mail", onPressed: () {}),
                  ],
                ),
              ),

              20.gap,

              /// Call Card
              AppCardContainer(
                child: Row(
                  children: [
                    AppText(
                      text: 'Talk on Call: ',
                      size: 18,
                      weight: FontWeight.w500,
                    ),
                    AppText(
                      text:
                          ' ${contactPhone.isNotEmpty ? contactPhone : 'Loading...'}',
                      size: 18,
                      color: Color(0xFFD67A3A),
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
