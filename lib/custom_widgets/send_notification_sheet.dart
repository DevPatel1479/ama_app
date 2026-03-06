// 🔹 Imports remain same
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/provider/notifications/notification_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/scheduled_notification_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/weekly_client_count_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SendNotificationSheet extends StatefulWidget {
  final String userId;

  const SendNotificationSheet({Key? key, required this.userId})
    : super(key: key);

  @override
  State<SendNotificationSheet> createState() => _SendNotificationSheetState();
}

class _SendNotificationSheetState extends State<SendNotificationSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool allClients = false;
  bool allAdvocates = false;
  bool allUsers = false;
  bool allLegalExperts = false;

  // Weekly switch and selection
  bool weeklyNotification = false;
  Map<String, bool> selectedWeeks = {
    'first_week': false,
    'second_week': false,
    'third_week': false,
    'fourth_week': false,
  };

  bool get isFormValid =>
      _titleController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty &&
      ((allClients ||
              allAdvocates ||
              allUsers ||
              allLegalExperts) || // regular roles
          (weeklyNotification && selectedWeeks.containsValue(true))); // weekly

  bool get isScheduleNotifFormValid {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasBody = _bodyController.text.trim().isNotEmpty;
    final hasDate = scheduledDate != null;
    final hasTime = scheduledTime != null;
    final hasAtLeastOneRole =
        scheduledAllClients ||
        scheduledAllAdvocates ||
        scheduledAllUsers ||
        scheduledAllLegalExperts;

    return hasTitle && hasBody && hasDate && hasTime && hasAtLeastOneRole;
  }

  bool scheduleNotification = false;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool isSchedulePage = false;
  bool scheduledAllClients = false;
  bool scheduledAllAdvocates = false;
  bool scheduledAllUsers = false;
  bool scheduledAllLegalExperts = false;
  @override
  void initState() {
    super.initState();
    // NOTE: removed initial fetch here — we fetch only when user toggles the switch.
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  DateTime? get scheduledDateTime {
    if (scheduledDate == null || scheduledTime == null) return null;
    return DateTime(
      scheduledDate!.year,
      scheduledDate!.month,
      scheduledDate!.day,
      scheduledTime!.hour,
      scheduledTime!.minute,
    ).toUtc(); // UTC time for cloud function
  }

  Widget buildMainPage(
    double screenWidth,
    double screenHeight,
    NotificationProvider notificationProvider,
    WeeklyClientCountProvider weeklyProvider,
    Map<String, int> counts,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // 🔹 Header
          Padding(
            padding: EdgeInsets.symmetric(
              // horizontal: screenWidth * 0.04 * 0.70,
              vertical: screenHeight * 0.015,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // GestureDetector(
                //   onTap: () => Navigator.pop(context),
                //   child: Icon(
                //     Icons.arrow_back_ios_new_rounded,
                //     color: Colors.white,
                //     size: screenWidth * 0.06 * 0.75,
                //   ),
                // ),
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24, // optional, makes tap area bigger
                ),
                Text(
                  "Send Notification",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.05 * 0.85,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04 * 0.85,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Notification Title",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.045 * 0.85,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    buildGradientInput(
                      controller: _titleController,
                      hintText: "Enter Title...",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Body
                    Text(
                      "Notification Body",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.045 * 0.85,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    buildGradientInput(
                      controller: _bodyController,
                      hintText: "Enter Message...",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // 🔹 Weekly Notification Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Send Weekly Client Notification",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.045 * 0.85,
                            color: Colors.white,
                          ),
                        ),
                        Switch(
                          value: weeklyNotification,
                          onChanged: (val) async {
                            // Toggle local state immediately for UI responsiveness
                            setState(() => weeklyNotification = val);

                            // If turned ON -> fetch counts and show loader
                            if (val) {
                              final weeklyProv =
                                  Provider.of<WeeklyClientCountProvider>(
                                    context,
                                    listen: false,
                                  );
                              try {
                                await weeklyProv.fetchWeeklyClientCount();
                                // leave current selectedWeeks as is (user can toggle)
                              } catch (e) {
                                // optional: show snackbar or error
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to load weekly counts",
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              // If turned OFF -> clear selected weeks
                              setState(() {
                                selectedWeeks = {
                                  'first_week': false,
                                  'second_week': false,
                                  'third_week': false,
                                  'fourth_week': false,
                                };
                              });
                            }
                          },
                          activeColor: const Color(0xFFD29F2A),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Schedule Notification",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.045 * 0.85,
                            color: Colors.white,
                          ),
                        ),
                        Switch(
                          value: scheduleNotification,
                          onChanged: (val) {
                            if (val) {
                              // User toggled ON → move to schedule page
                              setState(() {
                                scheduleNotification = true;
                                isSchedulePage = true;
                              });
                            } else {
                              // If user toggles OFF, just reset
                              setState(() {
                                scheduleNotification = false;
                                isSchedulePage = false;
                              });
                            }
                          },
                          activeColor: const Color(0xFFD29F2A),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Weekly checkboxes or loader
                    if (weeklyNotification)
                      weeklyProvider.loading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: selectedWeeks.keys.map((weekKey) {
                                final count = counts[weekKey] ?? 0;
                                // formatted label e.g. "First Week (10)" — you can change text if needed
                                final label = "$weekKey ($count)";
                                return CheckboxListTile(
                                  activeColor: const Color(0xFFD29F2A),
                                  title: Text(
                                    label,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04 * 0.85,
                                    ),
                                  ),
                                  value: selectedWeeks[weekKey],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedWeeks[weekKey] = val ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                    // 🔹 Role Selection (only when switch is OFF)
                    if (!weeklyNotification) ...[
                      Text(
                        "Select Role",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.045 * 0.85,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      CheckboxListTile(
                        activeColor: const Color(0xFFD29F2A),
                        title: Text(
                          "All Clients",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04 * 0.85,
                          ),
                        ),
                        value: allClients,
                        onChanged: (val) =>
                            setState(() => allClients = val ?? false),
                      ),
                      CheckboxListTile(
                        activeColor: const Color(0xFFD29F2A),
                        title: Text(
                          "All Advocates",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04 * 0.85,
                          ),
                        ),
                        value: allAdvocates,
                        onChanged: (val) =>
                            setState(() => allAdvocates = val ?? false),
                      ),
                      CheckboxListTile(
                        activeColor: const Color(0xFFD29F2A),
                        title: Text(
                          "All Users",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04 * 0.85,
                          ),
                        ),
                        value: allUsers,
                        onChanged: (val) =>
                            setState(() => allUsers = val ?? false),
                      ),
                      CheckboxListTile(
                        activeColor: const Color(0xFFD29F2A),
                        title: Text(
                          "All Legal Experts",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04 * 0.85,
                          ),
                        ),
                        value: allLegalExperts,
                        onChanged: (val) =>
                            setState(() => allLegalExperts = val ?? false),
                      ),
                    ],

                    SizedBox(height: screenHeight * 0.02),

                    // Submit Button
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.9 * 0.85,
                        height: screenHeight * 0.065,
                        child: ElevatedButton(
                          onPressed:
                              isFormValid && !notificationProvider.isLoading
                              ? () async {
                                  setState(() {});

                                  if (weeklyNotification) {
                                    // Weekly selected topics
                                    final selectedTopics = selectedWeeks.entries
                                        .where((e) => e.value)
                                        .map((e) => e.key)
                                        .toList();

                                    if (selectedTopics.isEmpty) return;

                                    await notificationProvider.sendNotification(
                                      context: context,
                                      userId: widget.userId,
                                      topic: "",
                                      title: _titleController.text.trim(),
                                      body: _bodyController.text.trim(),
                                      topics: selectedTopics,
                                      send_weekly: true,
                                    );
                                  } else {
                                    // Regular roles logic
                                    final selectedTopics = <String>[];
                                    if (allClients)
                                      selectedTopics.add("all_clients");
                                    if (allAdvocates)
                                      selectedTopics.add("all_advocates");
                                    if (allUsers)
                                      selectedTopics.add("all_users");
                                    if (allLegalExperts)
                                      selectedTopics.add("all_legal_experts");

                                    await notificationProvider.sendNotification(
                                      context: context,
                                      userId: widget.userId,
                                      topic: "",
                                      title: _titleController.text.trim(),
                                      body: _bodyController.text.trim(),
                                      topics: selectedTopics,
                                    );
                                  }

                                  if (mounted) {
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.black.withOpacity(0.3),
                            elevation: 6,
                            disabledBackgroundColor: Colors.grey.withOpacity(
                              0.3,
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: isFormValid
                                  ? const LinearGradient(
                                      begin: Alignment(-1.0, 0.0),
                                      end: Alignment(1.0, 0.0),
                                      colors: [
                                        Color(0xFFD29F2A),
                                        Color(0xFFFFFFFF),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [Colors.grey, Colors.grey],
                                    ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: notificationProvider.isLoading
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      child: const CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : Text(
                                      "Send Notification",
                                      style: GoogleFonts.outfit(
                                        fontSize: screenWidth * 0.045 * 0.85,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScheduledRoleCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Role", style: GoogleFonts.outfit(color: Colors.white)),
        CheckboxListTile(
          activeColor: const Color(0xFFD29F2A),
          title: Text(
            "All Clients",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          value: scheduledAllClients,
          onChanged: (val) =>
              setState(() => scheduledAllClients = val ?? false),
        ),
        CheckboxListTile(
          activeColor: const Color(0xFFD29F2A),
          title: Text(
            "All Advocates",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          value: scheduledAllAdvocates,
          onChanged: (val) =>
              setState(() => scheduledAllAdvocates = val ?? false),
        ),
        CheckboxListTile(
          activeColor: const Color(0xFFD29F2A),
          title: Text(
            "All Users",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          value: scheduledAllUsers,
          onChanged: (val) => setState(() => scheduledAllUsers = val ?? false),
        ),
        CheckboxListTile(
          activeColor: const Color(0xFFD29F2A),
          title: Text(
            "All Legal Experts",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          value: scheduledAllLegalExperts,
          onChanged: (val) =>
              setState(() => scheduledAllLegalExperts = val ?? false),
        ),
      ],
    );
  }

  Widget buildSchedulePage(
    double screenWidth,
    double screenHeight,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back and Close
          Padding(
            padding: EdgeInsets.symmetric(
              // horizontal: screenWidth * 0.04 * 0.70,
              vertical: screenHeight * 0.015,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () => setState(() {
                    isSchedulePage = false;
                    scheduleNotification = false;
                  }),
                  splashRadius: 24, // optional, makes tap area bigger
                ),
                Text(
                  "Schedule Notification",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.05 * 0.85,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context), // close bottom sheet
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04 * 0.85,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Body inputs (same as main page)
                    Text(
                      "Notification Title",
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    buildGradientInput(
                      controller: _titleController,
                      hintText: "Enter Title...",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      "Notification Body",
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    buildGradientInput(
                      controller: _bodyController,
                      hintText: "Enter Message...",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Role selection for schedule notification
                    buildScheduledRoleCheckboxes(),

                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final today = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: today,
                              firstDate: today,
                              lastDate: DateTime(today.year + 5),
                            );
                            if (picked != null)
                              setState(() => scheduledDate = picked);
                          },
                          child: Text(
                            scheduledDate == null
                                ? "Select Date"
                                : "${scheduledDate!.day}-${scheduledDate!.month}-${scheduledDate!.year}",
                          ),
                        ),

                        // Time picker
                        ElevatedButton(
                          onPressed: () async {
                            final now = TimeOfDay.now();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              setState(() => scheduledTime = picked);
                          },
                          child: Text(
                            scheduledTime == null
                                ? "Select Time"
                                : "${scheduledTime!.format(context)}",
                          ),
                        ),
                      ],
                    ),

                    // Date picker
                    SizedBox(height: screenHeight * 0.03),
                    Consumer<ScheduledNotificationProvider>(
                      builder: (context, provider, _) {
                        final isLoading = provider.status == ApiStatus.loading;

                        return Center(
                          child: SizedBox(
                            width: screenWidth * 0.9 * 0.85,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed:
                                  (!isScheduleNotifFormValid || isLoading)
                                  ? null
                                  : () async {
                                      final selectedTopics = <String>[];
                                      if (scheduledAllClients)
                                        selectedTopics.add("all_clients");
                                      if (scheduledAllAdvocates)
                                        selectedTopics.add("all_advocates");
                                      if (scheduledAllUsers)
                                        selectedTopics.add("all_users");
                                      if (scheduledAllLegalExperts)
                                        selectedTopics.add("all_legal_experts");
                                      final localDateTime = DateTime(
                                        scheduledDate!.year,
                                        scheduledDate!.month,
                                        scheduledDate!.day,
                                        scheduledTime!.hour,
                                        scheduledTime!.minute,
                                      );

                                      final utcDateTime = localDateTime.toUtc();
                                      final success = await provider
                                          .createScheduledNotification(
                                            userId: widget.userId,
                                            topics: selectedTopics,
                                            title: _titleController.text.trim(),
                                            body: _bodyController.text.trim(),
                                            scheduledAtUtc: utcDateTime
                                                .toIso8601String(),
                                          );

                                      if (!mounted) return;

                                      if (success) {
                                        showCustomMessage(
                                          context,
                                          "Notification scheduled successfully",
                                          false,
                                        );

                                        // Reset UI
                                        provider.reset();
                                        _titleController.clear();
                                        _bodyController.clear();
                                        setState(() {
                                          scheduledDate = null;
                                          scheduledTime = null;

                                          // selectedRoles.clear();
                                        });

                                        if (mounted) {
                                          await Future.delayed(
                                            const Duration(seconds: 2),
                                          );
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        showCustomMessage(
                                          context,
                                          "Failed to schedule notification",
                                          false,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.black.withOpacity(0.3),
                                elevation: 6,
                                disabledBackgroundColor: Colors.grey
                                    .withOpacity(0.3),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient:
                                      (!isScheduleNotifFormValid || isLoading)
                                      ? const LinearGradient(
                                          colors: [Colors.grey, Colors.grey],
                                        )
                                      : const LinearGradient(
                                          begin: Alignment(-1.0, 0.0),
                                          end: Alignment(1.0, 0.0),
                                          colors: [
                                            Color(0xFFD29F2A),
                                            Color(0xFFFFFFFF),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          "Schedule Notification",
                                          style: GoogleFonts.outfit(
                                            fontSize:
                                                screenWidth * 0.045 * 0.85,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Submit button
                    // buildSubmitButton(screenWidth, screenHeight, isSchedule: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const scaleFactor = 0.70;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * scaleFactor;
    final notificationProvider = Provider.of<NotificationProvider>(context);
    // We listen to the weekly provider so UI updates when loading/data changes.
    final weeklyProvider = Provider.of<WeeklyClientCountProvider>(context);

    // Build a safe counts map from provider (avoids toJson usage)
    final counts = {
      'first_week':
          weeklyProvider.weeklyClientCount?.totalClientsByWeek.firstWeek ?? 0,
      'second_week':
          weeklyProvider.weeklyClientCount?.totalClientsByWeek.secondWeek ?? 0,
      'third_week':
          weeklyProvider.weeklyClientCount?.totalClientsByWeek.thirdWeek ?? 0,
      'fourth_week':
          weeklyProvider.weeklyClientCount?.totalClientsByWeek.fourthWeek ?? 0,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return isSchedulePage
            ? buildSchedulePage(screenWidth, screenHeight, scrollController)
            : buildMainPage(
                screenWidth,
                screenHeight,
                notificationProvider,
                weeklyProvider,
                counts,
                scrollController,
              );
      },
    );
  }

  Widget buildGradientInput({
    required TextEditingController controller,
    required String hintText,
    required double screenWidth,
    required double screenHeight,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Container(
      width: screenWidth * 0.92,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(210, 159, 42, 0.65),
            Color.fromRGBO(255, 255, 255, 0.65),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2319),
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.outfit(
            fontSize: screenWidth * 0.04 * 0.85,
            fontWeight: FontWeight.w300,
            color: const Color(0xBFFFFFFF),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.outfit(
              fontSize: screenWidth * 0.04 * 0.85,
              fontWeight: FontWeight.w300,
              color: const Color(0xBFFFFFFF),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * 0.85,
              vertical: screenHeight * 0.015,
            ),
          ),
        ),
      ),
    );
  }
}
