import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({Key? key}) : super(key: key);

  @override
  State<TwoStepVerificationScreen> createState() => _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isEnabled = user?.email != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Two-Step Verification'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 24),
            _buildStatusCard(),
            SizedBox(height: 24),
            _buildHowItWorksSection(),
            SizedBox(height: 24),
            if (!_isEnabled) _buildEnableButton(),
            if (_isEnabled) _buildDisableButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: Colors.blue, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhanced Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Two-step verification adds an extra layer of security to your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEnabled ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEnabled ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEnabled ? Icons.check_circle : Icons.info_outline,
            color: _isEnabled ? Colors.green : Colors.grey[600],
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isEnabled ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildStep(
          number: '1',
          title: 'Email Verification',
          description: 'When you log in, we\'ll send a verification code to your email.',
        ),
        SizedBox(height: 12),
        _buildStep(
          number: '2',
          title: 'Enter Code',
          description: 'Enter the 6-digit code from your email to complete login.',
        ),
        SizedBox(height: 12),
        _buildStep(
          number: '3',
          title: 'Stay Protected',
          description: 'Your account is now protected with an extra layer of security.',
        ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnableButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _enableVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Enable Two-Step Verification',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDisableButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _disableVerification,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Disable Two-Step Verification',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _enableVerification() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Two-Step Verification'),
        content: Text(
          'A verification code will be sent to your email whenever you log in. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isEnabled = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Two-step verification enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _disableVerification() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disable Two-Step Verification'),
        content: Text(
          'Your account will be less secure without two-step verification. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isEnabled = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Two-step verification disabled'),
                ),
              );
            },
            child: Text('Disable', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}