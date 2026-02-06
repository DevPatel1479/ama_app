import 'dart:ui';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/config/constants/form_data.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DarkPortfolioScreen extends StatefulWidget {
  final String userRole;
  const DarkPortfolioScreen({super.key, required this.userRole});
  @override
  _DarkPortfolioScreenState createState() => _DarkPortfolioScreenState();
}

class _DarkPortfolioScreenState extends State<DarkPortfolioScreen>
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

      if (widget.userRole == "user") {
        await provider.getLeadByPhone(context);
      } else {
        await provider.fetchUserInfo(context, false);
      }
      _initializeControllers(provider);
      // Provider.of<UserInfoProvider>(
      //   context,
      //   listen: false,
      // ).fetchUserInfo(context, false);
    });

    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      double newOpacity = (offset / 150).clamp(0, 1);
      if (newOpacity != _appBarOpacity) {
        setState(() {
          _appBarOpacity = newOpacity;
        });
      }
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardOpen) {
      setState(() => _isKeyboardOpen = newValue);
    }
  }

  void _initializeControllers(UserInfoProvider provider) {
    if (widget.userRole == "user" && provider.leadsInfo?.data != null) {
      final data = provider.leadsInfo!.data!;
      _nameController.text = data.name ?? "";
      _emailController.text = data.email ?? "";
      _phoneController.text = data.phone ?? "";
      selectedState = data.state ?? "";
    } else if (provider.userInfo != null) {
      final data = provider.userInfo!;
      _nameController.text = data.name ?? "";
      _emailController.text = data.email ?? "";
      _phoneController.text = data.phone ?? "";
    }
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

  Widget buildSectionHeader(String title, {bool showEdit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: title == "Personal Information"
                  ? const Color(0xFF337EFF)
                  : const Color(0xFF008C38),
            ),
          ),
          // if (showEdit)
          //   Row(
          //     children: [
          //       Image.asset(AppAssets.editIcon, width: 18, height: 18),
          //       const SizedBox(width: 8),
          //       Text(
          //         "Edit",
          //         style: GoogleFonts.outfit(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w500,
          //           color: const Color(0xB2FFFFFF),
          //         ),
          //       ),
          //     ],
          //   ),
        ],
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
        _isEditing && (label == "Name" || label == "Email" || label == "State");
    final controller = label == "Name"
        ? _nameController
        : label == "Email"
        ? _emailController
        : label == "State"
        ? _stateController
        : null;

    if (controller != null && controller.text.isEmpty) {
      controller.text = value;
    }
    final financialLabels = [
      "Monthly Income",
      "Monthly Fees",
      "Credit Card Dues",
      "Personal Loan Dues",
    ];
    final isFinancial = financialLabels.contains(label);

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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(240, 57, 60, 32),
              borderRadius: BorderRadius.circular(15),
            ),
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade800,
                    highlightColor: Colors.grey.shade600,
                    child: Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : isEditable
                ? (label == "State"
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.black87,
                            value: selectedState?.isNotEmpty == true
                                ? selectedState
                                : null,
                            hint: Text(
                              "Select State",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.045,
                                color: Colors.white54,
                              ),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            isExpanded: true,
                            items: FormData.indianStates
                                .map<DropdownMenuItem<String>>((String state) {
                                  return DropdownMenuItem<String>(
                                    value: state,
                                    child: Text(
                                      state,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                  );
                                })
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
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "",
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ))
                : Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      resizeToAvoidBottomInset: true,

      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          final isLoading = widget.userRole == "user"
              ? provider.isFetching
              : provider.isLoading;
          final user = provider.userInfo;
          final leads = provider.leadsInfo;

          // print(leads?.data);

          final leadFields = [
            {"label": "Name", "value": leads?.data?.name ?? ""},
            {"label": "Email", "value": leads?.data?.email ?? ""},
            {"label": "Phone", "value": leads?.data?.phone ?? ""},
            {"label": "State", "value": leads?.data?.state ?? ""},
          ];

          // Map labels -> values from API model
          final fields = [
            {"label": "Name", "value": user?.name ?? ""},
            {"label": "Phone", "value": user?.phone ?? ""},
            {"label": "E-mail", "value": user?.email ?? ""},
            {"label": "City", "value": user?.city ?? ""},
            {"label": "Date of Birth", "value": user?.dob ?? ""},
            {"label": "Occupation", "value": user?.occupation ?? ""},
            {"label": "Aadhar Number", "value": user?.aadharNumber ?? ""},
            {"label": "PAN Card Number", "value": user?.panNumber ?? ""},
            // {"label": "Assigned To", "value": user?.status ?? ""},
            {"label": "Assigned Advocate", "value": user?.allocAdv ?? ""},
            // {
            //   "label": "Advocate Assigned At",
            //   "value": user?.allocAdvAt?["_seconds"].toString() ?? "",
            // },
            {
              "label": "Secondary Advocate",
              "value": user?.allocAdvSecondary ?? "",
            },
            // {"label": "Monthly Income", "value": user?.monthlyIncome ?? ""},
            // {"label": "Monthly Fees", "value": user?.monthlyFees ?? ""},
            // {"label": "Credit Card Dues", "value": user?.creditCardDues ?? ""},
            // {
            //   "label": "Personal Loan Dues",
            //   "value": user?.personalLoanDues ?? "",
            // },
            // {"label": "Tenure", "value": user?.tenure ?? ""},
            // {"label": "Start Date", "value": user?.startDate ?? ""},
            // {"label": "Source", "value": user?.sourceDatabase ?? ""},
          ];

          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // 5% of screen width
                  vertical: screenHeight * 0.12, // 12% of screen height
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    widget.userRole == "user"
                        ? leadFields.length
                        : fields.length,
                    (index) {
                      List<Widget> widgets = [];

                      if (index == 0) {
                        widgets.add(
                          buildSectionHeader(
                            "Personal Information",
                            showEdit: true,
                          ),
                        );
                      }

                      // if (fields[index]["label"] == "Monthly Income") {
                      //   widgets.add(buildSectionHeader("Financial Information"));
                      // }

                      widgets.add(
                        buildField(
                          widget.userRole == "user"
                              ? leadFields[index]['label']!
                              : fields[index]["label"]!,
                          widget.userRole == "user"
                              ? leadFields[index]['value']!
                              : fields[index]["value"]!,
                          isLoading,
                          screenWidth,
                        ),
                      );

                      return Column(children: widgets);
                    },
                  ),
                ),
              ),
              if (_isEditing && !_isKeyboardOpen)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              _initializeControllers(
                                Provider.of<UserInfoProvider>(
                                  context,
                                  listen: false,
                                ),
                              );
                            });
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.outfit(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF337EFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final provider = Provider.of<UserInfoProvider>(
                              context,
                              listen: false,
                            );
                            provider.updateUserData(
                              context,
                              phone: _phoneController.text.trim(),
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              state: selectedState ?? "",
                            );
                            setState(() {
                              _isEditing = false;
                            });
                          },

                          child: Text(
                            "Update",
                            style: GoogleFonts.outfit(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Modern transparent AppBar
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12,
                      // left: 16,
                      // right: screenWidth * 0.02,
                      bottom: 16,
                    ),
                    color: Colors.black.withOpacity(
                      _appBarOpacity * 0.3 + 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              IconButton(
                                padding:
                                    EdgeInsets.zero, // remove default padding

                                icon: Image.asset(
                                  AppAssets.backArrowIcon,
                                  width: screenWidth * 0.06,
                                  height: screenWidth * 0.06,
                                  fit: BoxFit.contain,
                                  // color: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(context),
                                splashRadius:
                                    24, // optional, makes tap area bigger
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Portfolio",
                                style: GoogleFonts.outfit(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.065,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.userRole == "user")
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.isUpdating)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
