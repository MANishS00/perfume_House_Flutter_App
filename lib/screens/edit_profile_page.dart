import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              /// Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              /// First Name
              _Label(text: 'First Name'),
              _InputField(),

              /// Last Name
              _Label(text: 'Last Name (optional)'),
              _InputField(),

              /// Mobile Number
              _Label(text: 'Mobile Number'),
              _InputField(keyboardType: TextInputType.phone),

              /// Gmail
              _Label(text: 'Gmail'),
              _InputField(keyboardType: TextInputType.emailAddress),

              /// Address 1
              _Label(text: 'Address 1'),
              _InputField(),

              /// Address 2
              _Label(text: 'Address 2'),
              _InputField(),

              /// City & State
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(text: 'City'),
                        _InputField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(text: 'State'),
                        _InputField(),
                      ],
                    ),
                  ),
                ],
              ),

              /// Pincode
              _Label(text: 'Pincode'),
              _InputField(keyboardType: TextInputType.number),

              const SizedBox(height: 30),

              /// Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2D33),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextInputType keyboardType;

  const _InputField({this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        keyboardType: keyboardType,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
