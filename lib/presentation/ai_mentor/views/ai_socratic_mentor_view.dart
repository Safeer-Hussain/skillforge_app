import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/ai_socratic_mentor_cubit.dart';
import '../cubit/ai_socratic_mentor_state.dart';
import '../../../data/models/cohort_and_mentor_models.dart';
import '../../../core/utils/app_feedback.dart';

class AiSocraticMentorView extends StatefulWidget {
  const AiSocraticMentorView({super.key});

  @override
  State<AiSocraticMentorView> createState() => _AiSocraticMentorViewState();
}

class _AiSocraticMentorViewState extends State<AiSocraticMentorView> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _promptShortcuts = [
    'Review My Sandbox Solution & Suggest Big-O Optimization',
    'Quiz Me With a Senior Flutter Architecture Question',
    'Audit My Weakest Flashcard Topics',
    'Build a 7-Day Staff Engineer Study Plan',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocConsumer<AiSocraticMentorCubit, AiSocraticMentorState>(
      listener: (context, state) {
        _scrollToBottom();
        if (state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.surface,
          resizeToAvoidBottomInset: true, // Keyboard safety rule
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Text(
              'On-Device AI Socratic Mentor',
              style: TextStyle(
                fontSize: isLandscape ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Reset Conversation',
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  size: isLandscape ? 18 : 20,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () {
                  context.read<AiSocraticMentorCubit>().clearConversation();
                  AppFeedback.showInfo(
                    context,
                    'Reset Socratic inquiry session.',
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Chat Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return _buildMessageBubble(context, msg);
                  },
                ),
              ),

              // Transient Analyzing Indicator
              if (state.isAnalyzingTelemetry)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Analyzing sandbox AST output, SM-2 retention intervals & skill gaps...',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Socratic Prompt Shortcuts
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _promptShortcuts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final prompt = _promptShortcuts[idx];
                    return ActionChip(
                      label: Text(
                        prompt,
                        style: TextStyle(fontSize: 11, color: cs.onSurface),
                      ),
                      backgroundColor: cs.surfaceContainer,
                      side: BorderSide(color: cs.outlineVariant),
                      padding: EdgeInsets.zero,
                      onPressed: state.isStreaming
                          ? null
                          : () {
                              context
                                  .read<AiSocraticMentorCubit>()
                                  .sendUserMessage(prompt);
                            },
                    );
                  },
                ),
              ),

              // Input Bar docked flush without double viewInsets
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          style: TextStyle(fontSize: 13, color: cs.onSurface),
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Pose an architectural question or AST dilemma...',
                            hintStyle: TextStyle(
                              fontSize: 12.5,
                              color: cs.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: cs.outlineVariant),
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty && !state.isStreaming) {
                              context
                                  .read<AiSocraticMentorCubit>()
                                  .sendUserMessage(val);
                              _promptController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: state.isStreaming
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.primary,
                                ),
                              )
                            : Icon(Icons.send_rounded, color: cs.primary),
                        onPressed: state.isStreaming
                            ? null
                            : () {
                                if (_promptController.text.trim().isNotEmpty) {
                                  context
                                      .read<AiSocraticMentorCubit>()
                                      .sendUserMessage(_promptController.text);
                                  _promptController.clear();
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, MentorMessageModel msg) {
    final cs = Theme.of(context).colorScheme;
    final isUser = msg.sender == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/mentor_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.psychology, size: 18, color: cs.primary),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? cs.primaryContainer.withValues(alpha: 0.3)
                    : cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser
                      ? cs.primary.withValues(alpha: 0.5)
                      : cs.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'Safeer Hussain (You)' : 'Socratic Mentor',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUser ? cs.primary : cs.secondary,
                        ),
                      ),
                      if (msg.isStreaming) ...[
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 15,
              backgroundColor: cs.primaryContainer,
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
