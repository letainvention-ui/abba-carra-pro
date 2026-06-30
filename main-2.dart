import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LetaSpinApp());
}

// ── Colors ──────────────────────────────────────────────────────────────────
const Color kBg        = Color(0xFF0A0A0A);
const Color kCard      = Color(0xFF111108);
const Color kGold      = Color(0xFFD4A017);
const Color kGoldDark  = Color(0xFFB8860B);
const Color kGoldBright= Color(0xFFFFD700);
const Color kPurple    = Color(0xFF7C3AED);
const Color kPurpleBright = Color(0xFFAB6FFF);
const Color kTicket    = Color(0xFF1C001C);
const Color kDanger    = Color(0xFFFF4444);
const Color kSuccess   = Color(0xFF22C55E);
const Color kText      = Color(0xFFF5F0DC);
const Color kMuted     = Color(0xFF8A8060);

// ── Owner Info ───────────────────────────────────────────────────────────────
const String kOwnerName    = 'Leta Bahiru';
const String kOwnerPhone   = '0995800079';
const String kOwnerAddress = 'Oromia, Ethiopia';
const String kDeveloper    = 'Deviloverr';
const String kAppName      = 'LETA SPIN PRO';
const String kTagline      = 'SPIN • WIN • REPEAT';

// ── Data Models ─────────────────────────────────────────────────────────────
class Ticket {
  final String id;
  final int price;
  final String phone;
  final String time;
  Ticket({required this.id, required this.price, required this.phone, required this.time});
}

class DrawResult {
  final String ticketId;
  final String phone;
  final int prize;
  final String time;
  DrawResult({required this.ticketId, required this.phone, required this.prize, required this.time});
}

// ── App Root ─────────────────────────────────────────────────────────────────
class LetaSpinApp extends StatelessWidget {
  const LetaSpinApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        primaryColor: kGold,
        colorScheme: const ColorScheme.dark(primary: kGold, surface: kCard),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kGoldBright,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: kGoldBright, fontSize: 18,
            fontWeight: FontWeight.w900, letterSpacing: 2,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0005),
          selectedItemColor: kGoldBright,
          unselectedItemColor: kMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ── Main Shell with Bottom Nav ───────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  int balance = 500;
  final List<Ticket> myTickets = [];
  final List<Ticket> allTickets = [];
  final List<DrawResult> history = [];
  int _ticketCounter = 1000;

  void _buyTicket(int price) {
    if (balance < price) {
      _showToast('Balance ga\'aa miti! Deposit godhi.', isError: true);
      return;
    }
    final id = (++_ticketCounter).toString();
    final t = Ticket(
      id: id, price: price,
      phone: kOwnerPhone,
      time: TimeOfDay.now().format(context),
    );
    setState(() {
      balance -= price;
      myTickets.add(t);
      allTickets.add(t);
    });
    _showToast('✅ Ticket #$id bitatta! ($price ETB)', isError: false);
  }

  void _onWin(Ticket winner) {
    final isMe = myTickets.any((t) => t.id == winner.id);
    final prize = winner.price * 50;
    setState(() {
      history.insert(0, DrawResult(
        ticketId: winner.id,
        phone: winner.phone,
        prize: prize,
        time: TimeOfDay.now().format(context),
      ));
      if (history.length > 5) history.removeLast();
      if (isMe) balance += prize;
    });
    if (isMe) {
      _showToast('🏆 Moo\'atte! $prize ETB wallet seente!', isError: false);
    } else {
      _showToast('Draw xumurame. Ticket #${winner.id} mo\'ate.', isError: false);
    }
  }

  void _showToast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? kDanger : kSuccess,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        balance: balance,
        myTickets: myTickets,
        allTickets: allTickets,
        history: history,
        onBuyTicket: _buyTicket,
        onDeposit: () => setState(() => balance += 200),
        onWin: _onWin,
      ),
      const PaymentScreen(),
      const AdminScreen(),
      const ProposalScreen(),
    ];

    return Scaffold(
      body: screens[_tab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A002A), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Telebirr'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
            BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Proposal'),
          ],
        ),
      ),
    );
  }
}

// ── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  final int balance;
  final List<Ticket> myTickets;
  final List<Ticket> allTickets;
  final List<DrawResult> history;
  final void Function(int) onBuyTicket;
  final VoidCallback onDeposit;
  final void Function(Ticket) onWin;

  const HomeScreen({
    super.key,
    required this.balance,
    required this.myTickets,
    required this.allTickets,
    required this.history,
    required this.onBuyTicket,
    required this.onDeposit,
    required this.onWin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Column(children: [
          Text(kAppName, style: const TextStyle(color: kGoldBright, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
          Text(kTagline, style: const TextStyle(color: kPurpleBright, fontSize: 9, letterSpacing: 3)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('$balance ETB',
              style: const TextStyle(color: kGoldBright, fontWeight: FontWeight.w900))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Owner card
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A001A), Color(0xFF0A000A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPurple.withOpacity(0.5)),
              ),
              child: Row(children: [
                Container(
                  width: 42, height: 42, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kGold, kPurple]),
                  ),
                  child: const Center(child: Text('🎰', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text(kOwnerName, style: TextStyle(color: kGoldBright, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(kOwnerAddress, style: TextStyle(color: kMuted, fontSize: 11)),
                  Text('Dev: $kDeveloper', style: TextStyle(color: kPurpleBright, fontSize: 10)),
                ]),
              ]),
            ),
            const CountdownCard(),
            const SizedBox(height: 14),
            WalletCard(balance: balance, onDeposit: onDeposit),
            const SizedBox(height: 14),
            const _SectionLabel('TICKET BITADHU'),
            const SizedBox(height: 8),
            Row(
              children: [10, 50, 100].map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TicketCard(price: p, onBuy: onBuyTicket, canAfford: balance >= p),
                ),
              )).toList(),
            ),
            if (myTickets.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _SectionLabel('TICKET KEE'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: myTickets.map((t) => _TicketChip(t)).toList(),
              ),
            ],
            const SizedBox(height: 14),
            DrawEngineCard(tickets: allTickets, onWin: onWin),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _GoldDivider(),
              const SizedBox(height: 8),
              const _SectionLabel('DRAW HISTORY'),
              const SizedBox(height: 8),
              ...history.map((h) => _HistoryRow(h)),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Payment / Telebirr Screen ─────────────────────────────────────────────────
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('💳 TELEBIRR DEPOSIT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A001A), Color(0xFF0A000A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPurple),
                boxShadow: [BoxShadow(color: kPurple.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Column(children: [
                const Text('📱 TELEBIRR', style: TextStyle(color: kGoldBright, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3)),
                const SizedBox(height: 16),
                const _GoldDivider(),
                const SizedBox(height: 16),
                const Text('Lacney Erguf:', style: TextStyle(color: kMuted, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: kPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPurple.withOpacity(0.5)),
                  ),
                  child: const Text(
                    kOwnerPhone,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kGoldBright, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.person, color: kGold, size: 16),
                  SizedBox(width: 6),
                  Text(kOwnerName, style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.location_on, color: kMuted, size: 14),
                  SizedBox(width: 4),
                  Text(kOwnerAddress, style: TextStyle(color: kMuted, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('MAALLAQA ERGI'),
            const SizedBox(height: 10),
            ...[
              ['10 ETB', 'Ticket 1x argatta', Icons.confirmation_number],
              ['50 ETB', 'Ticket 5x argatta', Icons.star],
              ['100 ETB', 'Ticket 10x + Bonus', Icons.workspace_premium],
            ].map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0005),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGoldDark.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(item[2] as IconData, color: kGold, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item[0] as String, style: const TextStyle(color: kGoldBright, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(item[1] as String, style: const TextStyle(color: kMuted, fontSize: 11)),
                ])),
                const Icon(Icons.arrow_forward_ios, color: kMuted, size: 14),
              ]),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kSuccess.withOpacity(0.3)),
              ),
              child: const Text(
                '✅ Telebirr irratti lakkoofsa $kOwnerPhone ergii → screenshot natti ergi → ticket si\'itti kennama!',
                style: TextStyle(color: kSuccess, fontSize: 12, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Countdown ────────────────────────────────────────────────────────────────
class CountdownCard extends StatefulWidget {
  const CountdownCard({super.key});
  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  late DateTime _target;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _target = DateTime.now().add(const Duration(hours: 1));
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = _target.difference(DateTime.now());
    if (mounted) setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _fmt(_remaining.inHours);
    final m = _fmt(_remaining.inMinutes.remainder(60));
    final s = _fmt(_remaining.inSeconds.remainder(60));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0005), Color(0xFF0A0A00)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPurple.withOpacity(0.4)),
      ),
      child: Column(children: [
        const Text('NEXT DRAW IN', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 3)),
        const SizedBox(height: 6),
        Text('$h : $m : $s', style: const TextStyle(
          color: kGoldBright, fontSize: 32, fontWeight: FontWeight.w900,
          fontFamily: 'monospace', letterSpacing: 6,
        )),
      ]),
    );
  }
}

// ── Wallet Card ──────────────────────────────────────────────────────────────
class WalletCard extends StatelessWidget {
  final int balance;
  final VoidCallback onDeposit;
  const WalletCard({super.key, required this.balance, required this.onDeposit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1500), Color(0xFF0A0A00)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldDark),
        boxShadow: [BoxShadow(color: kGold.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Wallet Balance', style: TextStyle(color: kMuted, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 4),
            RichText(text: TextSpan(children: [
              TextSpan(text: '$balance', style: const TextStyle(color: kGoldBright, fontSize: 30, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              const TextSpan(text: '  ETB', style: TextStyle(color: kGold, fontSize: 14)),
            ])),
          ]),
          ElevatedButton.icon(
            onPressed: onDeposit,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Deposit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold, foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ticket Card ──────────────────────────────────────────────────────────────
class TicketCard extends StatelessWidget {
  final int price;
  final void Function(int) onBuy;
  final bool canAfford;
  const TicketCard({super.key, required this.price, required this.onBuy, required this.canAfford});

  String get _prize => {10: '500', 50: '2,500', 100: '5,000'}[price]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C001C), Color(0xFF0D0005)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGoldDark.withOpacity(canAfford ? 0.5 : 0.2)),
      ),
      child: Column(children: [
        const Text('TICKET', style: TextStyle(color: kMuted, fontSize: 9, letterSpacing: 2)),
        const SizedBox(height: 6),
        Text('$price', style: const TextStyle(color: kGoldBright, fontSize: 24, fontWeight: FontWeight.w900)),
        const Text('ETB', style: TextStyle(color: kGold, fontSize: 11)),
        const SizedBox(height: 8),
        const Text('Win up to', style: TextStyle(color: kMuted, fontSize: 9)),
        Text('$_prize ETB', style: const TextStyle(color: kSuccess, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canAfford ? () => onBuy(price) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? kGold : const Color(0xFF333333),
              foregroundColor: canAfford ? Colors.black : const Color(0xFF666666),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            child: const Text('Buy'),
          ),
        ),
      ]),
    );
  }
}

// ── Draw Engine ──────────────────────────────────────────────────────────────
class DrawEngineCard extends StatefulWidget {
  final List<Ticket> tickets;
  final void Function(Ticket) onWin;
  const DrawEngineCard({super.key, required this.tickets, required this.onWin});
  @override
  State<DrawEngineCard> createState() => _DrawEngineCardState();
}

class _DrawEngineCardState extends State<DrawEngineCard> {
  bool _drawing = false;
  String _display = '— — — —';
  Ticket? _winner;

  void _startDraw() {
    if (widget.tickets.isEmpty) return;
    setState(() { _drawing = true; _winner = null; });
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 80), (t) {
      final rand = widget.tickets[Random().nextInt(widget.tickets.length)];
      setState(() => _display = '#${rand.id}');
      count++;
      if (count > 20) {
        t.cancel();
        final winner = widget.tickets[Random().nextInt(widget.tickets.length)];
        setState(() { _drawing = false; _winner = winner; _display = '#${winner.id}'; });
        widget.onWin(winner);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0005), Color(0xFF050010)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPurple.withOpacity(0.4)),
      ),
      child: Column(children: [
        const Text('🎰 SPIN ENGINE', style: TextStyle(color: kMuted, fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4,
            color: _drawing ? kGoldBright : (_winner != null ? kSuccess : kMuted),
          ),
          child: Text(_display),
        ),
        if (_winner != null) ...[
          const SizedBox(height: 6),
          Text('Winner: ${_winner!.phone}', style: const TextStyle(color: kSuccess, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_drawing || widget.tickets.isEmpty) ? null : _startDraw,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_drawing || widget.tickets.isEmpty) ? const Color(0xFF333333) : kPurple,
              foregroundColor: (_drawing || widget.tickets.isEmpty) ? const Color(0xFF666666) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
            ),
            child: Text(_drawing ? '🎰 Spinning...' : widget.tickets.isEmpty ? 'No Tickets Yet' : '🎲 SPIN NOW'),
          ),
        ),
        if (widget.tickets.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Buy tickets to participate', style: TextStyle(color: kMuted, fontSize: 11)),
          ),
      ]),
    );
  }
}

// ── Admin Screen ─────────────────────────────────────────────────────────────
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      {'label': 'Total Users', 'value': '1,284'},
      {'label': 'Tickets Sold', 'value': '8,490'},
      {'label': 'Revenue (ETB)', 'value': '284,500'},
      {'label': 'Draws Run', 'value': '47'},
    ];
    final draws = [
      {'name': 'Daily Spin #1', 'price': '10', 'participants': '124', 'status': 'active'},
      {'name': 'Weekly VIP Spin', 'price': '100', 'participants': '38', 'status': 'pending'},
    ];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('⚙️ ADMIN PANEL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Owner info card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0005),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPurple.withOpacity(0.4)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('OWNER INFO', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 2)),
                SizedBox(height: 10),
                Text('👤  $kOwnerName', style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('📞  $kOwnerPhone (Telebirr)', style: TextStyle(color: kGoldBright, fontSize: 13)),
                SizedBox(height: 4),
                Text('📍  $kOwnerAddress', style: TextStyle(color: kMuted, fontSize: 12)),
                SizedBox(height: 4),
                Text('💻  Dev: $kDeveloper', style: TextStyle(color: kPurpleBright, fontSize: 12)),
              ]),
            ),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, crossAxisSpacing: 10,
              mainAxisSpacing: 10, childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: stats.map((s) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0005),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGoldDark.withOpacity(0.3)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(s['value']!, style: const TextStyle(color: kGoldBright, fontSize: 20, fontWeight: FontWeight.w900)),
                  Text(s['label']!, style: const TextStyle(color: kMuted, fontSize: 10)),
                ]),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const _GoldDivider(),
            const SizedBox(height: 8),
            const _SectionLabel('DRAW MANAGEMENT'),
            const SizedBox(height: 8),
            ...draws.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0005),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGoldDark.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['name']!, style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${d['price']} ETB · ${d['participants']} participants', style: const TextStyle(color: kMuted, fontSize: 11)),
                  ])),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (d['status'] == 'active' ? kSuccess : kGold).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: (d['status'] == 'active' ? kSuccess : kGold).withOpacity(0.4)),
                      ),
                      child: Text(d['status']!, style: TextStyle(
                        color: d['status'] == 'active' ? kSuccess : kGold,
                        fontSize: 10, fontWeight: FontWeight.w700,
                      )),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGold, side: const BorderSide(color: kGoldDark),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 11)),
                    ),
                  ]),
                ],
              ),
            )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create New Spin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Proposal Screen ──────────────────────────────────────────────────────────
class ProposalScreen extends StatelessWidget {
  const ProposalScreen({super.key});

  static const _sections = [
    {'icon': '🎯', 'title': 'Project Overview', 'body': 'Leta Spin Pro — $kOwnerName\'s Digital Spin Lottery System. Mobile app irratti hundaa\'e. Users ticket bitatan, system auto spin godha, winner Telebirr ($kOwnerPhone) payment argata.'},
    {'icon': '⚙️', 'title': 'Core Architecture', 'body': 'Frontend: Flutter App\nBackend: Node.js REST API\nDatabase: MongoDB\nSpin Engine: Server-side cryptographic random\nPayment: Telebirr ($kOwnerPhone), CBE, Awash, Coop Bank'},
    {'icon': '💰', 'title': 'Revenue Model', 'body': 'Ticket sales (main income)\nPlatform commission 10–30%\nPremium VIP spins\nReferral bonuses\nDeveloper: $kDeveloper'},
    {'icon': '🔐', 'title': 'Security', 'body': 'OTP login verification\nEncrypted wallet system\nAnti-fraud detection\nServer-side spin only\nFull transaction audit logs'},
    {'icon': '⚖️', 'title': 'Legal Requirements', 'body': 'Lottery/gaming license\nFinancial compliance approval\nAML policy\nNBE registration required\nOwner: $kOwnerName, $kOwnerAddress'},
    {'icon': '🚀', 'title': 'Future Expansion', 'body': 'Multi-country lottery\nCrypto payment integration\nLive spin streaming\nAI-based fraud detection'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('📄 PROPOSAL')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: kPurple.withOpacity(0.4)),
            ),
            child: const Text('INVESTOR READY — LETA SPIN PRO', textAlign: TextAlign.center,
              style: TextStyle(color: kPurpleBright, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          ),
          const SizedBox(height: 14),
          ..._sections.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0005),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGoldDark.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s['icon']} ${s['title']}',
                style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 8),
              Text(s['body']!, style: const TextStyle(color: kText, fontSize: 12, height: 1.7)),
            ]),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: kMuted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600));
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Colors.transparent, kGold, Colors.transparent]),
    ),
  );
}

class _TicketChip extends StatelessWidget {
  final Ticket t;
  const _TicketChip(this.t);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kTicket,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kGoldDark.withOpacity(0.4)),
    ),
    child: RichText(text: TextSpan(children: [
      const TextSpan(text: '#', style: TextStyle(color: kGold, fontFamily: 'monospace')),
      TextSpan(text: t.id, style: const TextStyle(color: kText, fontFamily: 'monospace', fontSize: 12)),
      TextSpan(text: '  ${t.price}ETB', style: const TextStyle(color: kMuted, fontSize: 10)),
    ])),
  );
}

class _HistoryRow extends StatelessWidget {
  final DrawResult h;
  const _HistoryRow(this.h);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF0D0005),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('#${h.ticketId}', style: const TextStyle(color: kGold, fontFamily: 'monospace', fontSize: 12)),
        Text(h.phone, style: const TextStyle(color: kText, fontSize: 12)),
        Text('+${h.prize} ETB', style: const TextStyle(color: kSuccess, fontSize: 12, fontWeight: FontWeight.w700)),
        Text(h.time, style: const TextStyle(color: kMuted, fontSize: 10)),
      ],
    ),
  );
}
