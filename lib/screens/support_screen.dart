import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  Timer? _replyTimer;
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messages.addAll(<_ChatMessage>[
      _ChatMessage(
        text:
            'Hi! I’m Ananya from Foodie support. How can I help you today?',
        isUser: false,
        time: DateTime.now(),
      ),
      _ChatMessage(
        text:
            'This is a simulated chat for the demo. Ask about orders, coupons, addresses or refunds.',
        isUser: false,
        time: DateTime.now(),
      ),
    ]);
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _replyFor(String message) {
    final String value = message.toLowerCase();
    if (value.contains('where') ||
        value.contains('track') ||
        value.contains('order') ||
        value.contains('late')) {
      return 'You can follow every step in Orders → Active. Tap your order to see the demo timeline and rider details. If the order is already delivered, it will be in History.';
    }
    if (value.contains('refund') || value.contains('money')) {
      return 'Refunds are simulated in this demo. For a real app, the amount would return to the original payment method within 3–5 business days.';
    }
    if (value.contains('coupon') ||
        value.contains('offer') ||
        value.contains('promo')) {
      return 'Try FOODIE50 (50% off up to ₹150, min ₹399) or FREEDEL (free delivery, min ₹199). Add items to your cart, then apply the code in the cart screen.';
    }
    if (value.contains('address') || value.contains('location')) {
      return 'You can change your delivery address from Profile → Saved addresses, or tap the address on the checkout screen. All addresses here are mock data.';
    }
    if (value.contains('payment') || value.contains('upi') || value.contains('card')) {
      return 'This is a demo, so Cash on Delivery, UPI and Card are all simulated. No payment details are ever requested or stored.';
    }
    if (value.contains('human') ||
        value.contains('agent') ||
        value.contains('call')) {
      return 'A human agent would join this chat in a real app. For now, I can help with orders, coupons, addresses and payments.';
    }
    return 'Thanks for reaching out! I’m a demo assistant, but I can help with orders, coupons, addresses and payment questions. What would you like to know?';
  }

  void _send([String? preset]) {
    final String text = (preset ?? _messageController.text).trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
      _typing = true;
      _messageController.clear();
    });
    _scrollToBottom();
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          _ChatMessage(
            text: _replyFor(text),
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _showCallSupport() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Call Foodie support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('+91 1800 202 3030', style: context.foodieType.h3),
            const SizedBox(height: 4),
            Text(
              'Every day, 9 AM – 11 PM',
              style: context.foodieType.small,
            ),
            const SizedBox(height: 14),
            Text(
              'Calls are simulated in this demo. No call will be placed.',
              style: context.foodieType.small.copyWith(fontSize: 10.5),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showFoodieSnack(
                this.context,
                'Demo call to Foodie support started',
                icon: Icons.call_rounded,
              );
            },
            icon: const Icon(Icons.call_rounded, size: 16),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(
        title: const Text('Help & support'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.foodie.primaryInk,
          labelColor: context.foodie.primaryInk,
          unselectedLabelColor: context.foodie.muted,
          labelStyle: context.foodieType.label.copyWith(fontSize: 11),
          tabs: const <Widget>[
            Tab(text: 'FAQs'),
            Tab(text: 'Live chat'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _FaqTab(
              onChatTap: () => _tabController.animateTo(1),
              onCallTap: _showCallSupport,
            ),
            _buildChatTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.foodie.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: context.foodieType.h3.copyWith(
                        color: context.foodie.primaryInk,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: context.foodie.info,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.foodie.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Ananya • Foodie Care',
                      style: context.foodieType.h3.copyWith(fontSize: 13.5),
                    ),
                    Text(
                      'Demo assistant • Usually replies instantly',
                      style: context.foodieType.small.copyWith(fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showCallSupport,
                style: IconButton.styleFrom(
                  backgroundColor: context.foodie.background,
                  minimumSize: const Size(34, 34),
                ),
                icon: const Icon(Icons.call_outlined, size: 17),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            itemCount: _messages.length + (_typing ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == _messages.length && _typing) {
                return const _TypingBubble();
              }
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              _QuickTopic(
                label: 'Where is my order?',
                onTap: () => _send('Where is my order?'),
              ),
              _QuickTopic(
                label: 'Coupon not working',
                onTap: () => _send('My coupon is not working'),
              ),
              _QuickTopic(
                label: 'Change address',
                onTap: () => _send('I want to change my delivery address'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type your message…',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.foodie.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _send,
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: context.foodie.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTab extends StatelessWidget {
  const _FaqTab({required this.onChatTap, required this.onCallTap});

  final VoidCallback onChatTap;
  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                context.foodie.panelDark,
                Color.lerp(
                  context.foodie.panelDark,
                  context.foodie.primary,
                  0.24,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'WE’RE HERE FOR YOU',
                style: context.foodieType.eyebrow.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 1.2,
                  color: context.foodie.gold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'How can we help?',
                style: context.foodieType.display.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Browse quick answers or start a chat with our demo assistant.',
                style: context.foodieType.small.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              // Two actions that must both stay reachable on a narrow hero:
              // they wrap onto separate lines rather than clipping.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onChatTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.foodie.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                      label: const Text('Start chat'),
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: onCallTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                      ),
                      icon: const Icon(Icons.call_outlined, size: 15),
                      label: const Text('Call us'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Frequently asked', style: context.foodieType.h3),
        const SizedBox(height: 9),
        Material(
          // A Material ancestor lets the tile's ink splashes paint on the
          // card instead of being hidden by a plain decorated box.
          color: context.foodie.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: context.foodie.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < MockData.faqs.length; i++) ...<Widget>[
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    iconColor: context.foodie.primaryInk,
                    collapsedIconColor: context.foodie.muted,
                    title: Text(
                      MockData.faqs[i].question,
                      style: context.foodieType.body.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          MockData.faqs[i].answer,
                          style: context.foodieType.small.copyWith(
                            fontSize: 11,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < MockData.faqs.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.foodie.surfaceWarm,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 17,
                color: context.foodie.primaryInk,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This is a fully local demo. Support responses are simulated and no messages are sent anywhere.',
                  style: context.foodieType.small.copyWith(
                    fontSize: 10.5,
                    color: context.foodie.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser, required this.time});

  final String text;
  final bool isUser;
  final DateTime time;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
        decoration: BoxDecoration(
          color: message.isUser
              ? context.foodie.primary
              : context.foodie.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(
              message.isUser ? AppRadius.md : AppRadius.sm,
            ),
            bottomRight: Radius.circular(
              message.isUser ? AppRadius.sm : AppRadius.md,
            ),
          ),
          border: message.isUser
              ? null
              : Border.all(color: context.foodie.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.text,
              style: context.foodieType.body.copyWith(
                fontSize: 12.2,
                height: 1.45,
                color: message.isUser
                    ? context.foodie.onPrimary
                    : context.foodie.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formatDate(message.time).split(', ').last,
              style: context.foodieType.small.copyWith(
                fontSize: 8,
                color: message.isUser
                    ? context.foodie.onPrimary
                    : context.foodie.subtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: context.foodie.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.foodie.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.8),
            ),
            const SizedBox(width: 7),
            Text(
              'Ananya is typing…',
              style: context.foodieType.small.copyWith(fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTopic extends StatelessWidget {
  const _QuickTopic({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        backgroundColor: context.foodie.surface,
        side: BorderSide(color: context.foodie.border),
        labelStyle: context.foodieType.label.copyWith(fontSize: 9.5),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
