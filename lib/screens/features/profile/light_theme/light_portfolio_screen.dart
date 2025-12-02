import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/config/constants/form_data.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LightPortfolioScreen extends StatefulWidget {
  final String userRole;
  const LightPortfolioScreen({super.key, required this.userRole});

  @override
  _LightPortfolioScreenState createState() => _LightPortfolioScreenState();
}

class _LightPortfolioScreenState extends State<LightPortfolioScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  bool _isEditing = false;
  bool _isKeyboardOpen = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController();

  String? selectedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() async {
      final provider = Provider.of<UserInfoProvider>(context, listen: false);
      print("role ${widget.userRole}");
      if (widget.userRole == "user") {
        await provider.getLeadByPhone(context);
      } else {
        await provider.fetchUserInfo(context, false);
      }
      _initializeControllers(provider);
    });

    _scrollController.addListener(() {
      final offset = _scroll_controller_safe().offset;
      final newOpacity = (offset / 150).clamp(0.0, 1.0);
      if (newOpacity != _appBarOpacity) {
        setState(() => _appBarOpacity = (newOpacity as num).toDouble());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserInfoProvider provider) {
    if (widget.userRole == "user" && provider.leadsInfo?.data != null) {
      final data = provider.leadsInfo!.data!;
      _nameController.text = data.name ?? "";
      _emailController.text = data.email ?? "";
      _phoneController.text = data.phone ?? "";
      selectedState = data.state ?? "";
      _stateController.text = selectedState ?? "";
    } else if (provider.userInfo != null) {
      final data = provider.userInfo!;
      _nameController.text = data.name ?? "";
      _emailController.text = data.email ?? "";
      _phone_controller_safe().text = data.phone ?? "";
      // DO NOT set selectedState here — userInfo has no state
    }
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: title == "Personal Information"
              ? const Color(0xFF337EFF)
              : const Color(0xFF008C38),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    String value,
    bool isLoading,
    double screenWidth,
  ) {
    final isEditable =
        _isEditing &&
        (label == "Name" ||
            label == "Email" ||
            (label == "State" && widget.userRole == "user"));
    final controller = label == "Name"
        ? _nameController
        : label == "Email"
        ? _emailController
        : label == "State"
        ? (widget.userRole == "user" ? _state_controller_safe() : null)
        : null;

    if (controller != null && controller.text.isEmpty) controller.text = value;

    final financialLabels = [
      "Monthly Income",
      "Monthly Fees",
      "Credit Card Dues",
      "Personal Loan Dues",
    ];
    final isFinancial = financialLabels.contains(label);

    final textColor = isFinancial ? const Color(0xFF008C38) : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x33D29F2A).withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade400,
                    highlightColor: Colors.grey.shade200,
                    child: Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : (isEditable
                      ? (label == "State"
                            ? DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  value: selectedState?.isNotEmpty == true
                                      ? selectedState
                                      : null,
                                  hint: Text(
                                    "Select State",
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                  ),
                                  isExpanded: true,
                                  items: FormData.indianStates
                                      .map<DropdownMenuItem<String>>(
                                        (String state) =>
                                            DropdownMenuItem<String>(
                                              value: state,
                                              child: Text(
                                                state,
                                                style: GoogleFonts.outfit(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedState = value;
                                      _stateController.text = value ?? '';
                                    });
                                  },
                                ),
                              )
                            : TextField(
                                controller: controller,
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ))
                      : Text(
                          value,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        )),
          ),
        ],
      ),
    );
  }

  TextEditingController _state_controller_safe() => _stateController;
  TextEditingController _phone_controller_safe() => _phoneController;
  ScrollController _scroll_controller_safe() => _scrollController;

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardOpen) {
      setState(() => _isKeyboardOpen = newValue);
    }
  }

  Future<void> _onUpdatePressed(UserInfoProvider provider) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _isEditing = false);
    await provider.updateUserData(
      context,
      phone: phone,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      state: widget.userRole == "user"
          ? (selectedState?.trim().isEmpty == true ? null : selectedState)
          : null,
    );

    if (widget.userRole == "user") {
      await provider.getLeadByPhone(context);
    } else {
      await provider.fetchUserInfo(context, false);
    }
    _initializeControllers(provider);
    // setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerVisualHeight = screenHeight * 0.03; // tweak if you need taller
    final appBarHeight =
        MediaQuery.of(context).padding.top + headerVisualHeight;

    final scaleFactor = 0.85;
    // We need provider here (for isUpdating) so use Consumer and then wrap everything in a top-level Stack
    return Scaffold(
      backgroundColor: Color(0xFFF8BD00),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        // ⭐ NATIVE WAY TO ROUND ONLY BOTTOM
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,

        title: Padding(
          padding: EdgeInsets.only(
            // top: MediaQuery.of(context).padding.top,
            left: screenWidth * 0.04 * scaleFactor,
            right: screenWidth * 0.04 * scaleFactor,
            // bottom: screenHeight * 0.015 * scaleFactor,
          ),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  AppAssets.backArrowIcon,
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  "Portfolio",
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              if (widget.userRole == "user")
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.01),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      color: Colors.black,
                      size: 26,
                    ),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                  ),
                ),
            ],
          ),
        ),
      ),

      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          final isLoading = widget.userRole == "user"
              ? provider.isFetching
              : provider.isLoading;
          final user = provider.userInfo;
          final leads = provider.leadsInfo;

          // Keep controllers in sync when not editing
          if (!_isEditing) {
            if (widget.userRole == "user" && leads?.data != null) {
              final d = leads!.data!;
              if (_nameController.text != (d.name ?? "")) {
                _nameController.text = d.name ?? "";
              }
              if (_emailController.text != (d.email ?? "")) {
                _emailController.text = d.email ?? "";
              }
              if (_phoneController.text != (d.phone ?? "")) {
                _phoneController.text = d.phone ?? "";
              }
              if ((selectedState ?? "") != (d.state ?? "")) {
                selectedState = d.state ?? "";
              }
              if (_stateController.text != selectedState) {
                _stateController.text = selectedState ?? "";
              }
            } else if (user != null) {
              if (_nameController.text != (user.name ?? "")) {
                _nameController.text = user.name;
              }
              if (_emailController.text != (user.email ?? "")) {
                _emailController.text = user.email;
              }
              if (_phoneController.text != (user.phone ?? "")) {
                _phoneController.text = user.phone;
              }
              // DO NOT set selectedState from user (userInfo has no state)
            }
          }

          final leadFields = [
            {"label": "Name", "value": leads?.data?.name ?? ""},
            {"label": "Email", "value": leads?.data?.email ?? ""},
            {"label": "Phone", "value": leads?.data?.phone ?? ""},
            {"label": "State", "value": leads?.data?.state ?? ""},
          ];

          final fields = [
            {"label": "Name", "value": user?.name ?? ""},
            {"label": "Phone", "value": user?.phone ?? ""},
            {"label": "E-mail", "value": user?.email ?? ""},
            {"label": "City", "value": user?.city ?? ""},
            {"label": "Date of Birth", "value": user?.dob ?? ""},
            {"label": "Occupation", "value": user?.occupation ?? ""},
            {"label": "Aadhar Number", "value": user?.aadharNumber ?? ""},
            {"label": "PAN Card Number", "value": user?.panNumber ?? ""},
            {"label": "Assigned Advocate", "value": user?.allocAdv ?? ""},
            {
              "label": "Secondary Advocate",
              "value": user?.allocAdvSecondary ?? "",
            },
          ];

          // Build headerContent with right-aligned edit icon
          // final headerContent = Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: screenWidth * 0.04,
          //     vertical: screenHeight * 0.015,
          //   ),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFD29F2A),
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(screenWidth * 0.07),
          //       bottomRight: Radius.circular(screenWidth * 0.07),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       GestureDetector(
          //         behavior: HitTestBehavior.translucent,
          //         onTap: () => Navigator.pop(context),
          //         child: Image.asset(
          //           AppAssets.backArrowIcon,
          //           width: screenWidth * 0.05,
          //           height: screenWidth * 0.05,
          //         ),
          //       ),
          //       SizedBox(width: screenWidth * 0.12),
          //       Expanded(
          //         child: Text(
          //           "Portfolio",
          //           style: GoogleFonts.outfit(
          //             fontSize: screenWidth * 0.065,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //       if (widget.userRole == "user")
          //         Padding(
          //           padding: EdgeInsets.only(right: screenWidth * 0.01),
          //           child: IconButton(
          //             visualDensity: VisualDensity.compact,
          //             icon: Icon(
          //               _isEditing ? Icons.close : Icons.edit,
          //               color: Colors.white,
          //               size: 26,
          //             ),
          //             onPressed: () => setState(() => _isEditing = !_isEditing),
          //           ),
          //         ),
          //     ],
          //   ),
          // );

          // Content passed inside GradientTopLayout: a Stack so we can position bottom buttons relative to scrollable area
          final contentStack = Stack(
            children: [
              // Scrollable content
              SingleChildScrollView(
                controller: _scroll_controller_safe(),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: screenHeight * 0.20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionHeader("Personal Information"),
                    ...List.generate(
                      widget.userRole == "user"
                          ? leadFields.length
                          : fields.length,
                      (index) {
                        final item = widget.userRole == "user"
                            ? leadFields[index]
                            : fields[index];
                        return buildField(
                          item['label']!,
                          item['value']!,
                          isLoading,
                          screenWidth,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom floating buttons
              if (_isEditing &&
                  !_isKeyboardOpen &&
                  !provider.isUpdating &&
                  !isLoading)
                Positioned(
                  bottom: screenHeight * 0.04,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[850],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _initializeControllers(provider);
                            });
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF337EFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: provider.isUpdating
                              ? null
                              : () => _onUpdatePressed(provider),
                          child: provider.isUpdating
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Update",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );

          // TOP-LEVEL STACK: GradientTopLayout below, overlay above so it covers entire screen
          return Stack(
            children: [
              GradientTopLayout(
                screenName: "home",
                // headerContent: headerContent,
                child: contentStack,
              ),
              // Full-screen transparent loader overlay (blocks interactions)
              if (provider.isUpdating)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
