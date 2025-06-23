import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../models/user_profile.dart';
import '../models/goal.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Gamificação'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
            Tab(icon: Icon(Icons.flag), text: 'Metas'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Conquistas'),
          ],
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, gamificationProvider, child) {
          if (gamificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(gamificationProvider),
              _buildGoalsTab(gamificationProvider),
              _buildAchievementsTab(gamificationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(GamificationProvider provider) {
    final userProfile = provider.userProfile;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card do perfil principal
        Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isDarkMode 
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar e informações básicas
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade600],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userProfile.levelEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile.username,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.headlineLarge?.color,
                              ),
                            ),
                            Text(
                              userProfile.levelName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.stars, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${userProfile.totalXP} XP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${userProfile.coins}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Barra de progresso do nível
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso do Nível',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            userProfile.level == UserLevel.master 
                                ? 'MAX' 
                                : '${userProfile.xpRequiredForNextLevel} XP restantes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: userProfile.levelProgress,
                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Estatísticas detalhadas
        _buildStatsGrid(provider),

        const SizedBox(height: 20),

        // Configurações do perfil
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Editar Nome'),
                  subtitle: Text(userProfile.username),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showEditUsernameDialog(context, provider),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.orange),
                  title: const Text('Resetar Progresso'),
                  subtitle: const Text('Voltar ao início (cuidado!)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showResetProgressDialog(context, provider),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(GamificationProvider provider) {
    final stats = provider.getUserStats();
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Badges',
          value: '${stats['badges']}',
          color: Colors.amber,
        ),
        _buildStatCard(
          icon: Icons.flag,
          title: 'Metas Concluídas',
          value: '${stats['completedGoals']}',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.calendar_today,
          title: 'Dias Ativos',
          value: '${stats['daysSinceStart']}',
          color: Colors.purple,
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          title: 'Nível',
          value: stats['level'],
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsTab(GamificationProvider provider) {
    final activeGoals = provider.activeGoals;
    final completedGoals = provider.completedGoals;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Metas ativas
        if (activeGoals.isNotEmpty) ...[
          Text(
            'Metas Ativas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...activeGoals.map((goal) => _buildGoalCard(goal, provider)),
          const SizedBox(height: 24),
        ],

        // Metas concluídas
        if (completedGoals.isNotEmpty) ...[
          Text(
            'Metas Concluídas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...completedGoals.take(5).map((goal) => _buildGoalCard(goal, provider)),
        ],

        // Botão para adicionar meta personalizada
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _showAddGoalDialog(context, provider),
          icon: const Icon(Icons.add),
          label: const Text('Criar Meta Personalizada'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, GamificationProvider provider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    goal.typeEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: goal.statusColor),
                    ),
                    child: Text(
                      goal.statusName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: goal.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Barra de progresso
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(goal.statusColor),
                minHeight: 6,
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentValue}/${goal.targetValue}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (goal.isActive) ...[
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${goal.daysRemaining} dias',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              if (goal.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${goal.xpReward} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.monetization_on, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${goal.coinReward}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationProvider provider) {
    final userProfile = provider.userProfile;
    final availableBadges = provider.availableBadges;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Conquistas e Badges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: availableBadges.length,
          itemBuilder: (context, index) {
            final badge = availableBadges[index];
            final isUnlocked = userProfile.unlockedBadges.contains(badge['id']);
            
            return _buildBadgeCard(badge, isUnlocked);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isUnlocked) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: isUnlocked 
          ? (isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.amber.shade50)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge['icon'],
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUnlocked 
                    ? (isDarkMode ? Colors.amber[300] : Colors.amber[700])
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked 
                    ? (isDarkMode ? Colors.amber[400] : Colors.amber[600])
                    : Colors.grey,
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'DESBLOQUEADO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog(BuildContext context, GamificationProvider provider) {
    final controller = TextEditingController(text: provider.userProfile.username);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome de usuário',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateUsername(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context, GamificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Resetar Progresso'),
        content: const Text(
          'Esta ação irá resetar TODO o seu progresso de gamificação (XP, nível, metas, badges). Esta ação NÃO pode ser desfeita.\n\nTem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Progresso resetado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, GamificationProvider provider) {
    // Para MVP, vamos mostrar uma mensagem simples
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚧 Em Desenvolvimento'),
        content: const Text('A funcionalidade de criar metas personalizadas estará disponível em breve!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
} 