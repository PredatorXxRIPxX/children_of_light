import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lumiers/auth/signin.dart';
import 'package:lumiers/utils/user_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileInfo(),
                      _buildUserDetailsCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.lightBlue],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {
            
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userProvider.username,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          userProvider.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }


  Widget _buildUserDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedStarCircle,
                color: Colors.blue,
                size: 24.0,
              ),
              label: 'Favories',
              value: 'Vos chants et quantines preférés',
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDownload04,
                color: Colors.green,
                size: 24.0,
              ),
              label: 'Téléchargements',
              value: 'Vos chants et quantines téléchargés',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required HugeIcon icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.edit,
          label: 'Edit Profile',
          onPressed: () {},
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.logout,
          label: 'Logout',
          onPressed: () {
            userProvider.logout();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const SignInPage(),
              ),
            );
          },
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
