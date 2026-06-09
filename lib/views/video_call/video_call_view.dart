import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

/// Full-screen video call view powered by Agora RTC.
///
/// Both the vet and the pet owner use this same screen.
/// [appId]       – Agora App ID
/// [token]       – Agora RTC token for this user
/// [channelName] – The Agora channel to join
/// [uid]         – Local user ID (vet = 1, owner = 2)
/// [remoteName]  – Display name of the remote user
/// [onCallEnded] – Callback fired when the call ends (to pop the screen and
///                 call the end-call API).
class VideoCallView extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int uid;
  final String remoteName;
  final VoidCallback onCallEnded;

  const VideoCallView({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.remoteName,
    required this.onCallEnded,
  });

  @override
  State<VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<VideoCallView> {
  late final RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isFrontCamera = true;
  bool _showControls = true;
  Timer? _controlsTimer;

  // Call duration
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _durationTimer;
  String _durationText = '00:00';

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startControlsAutoHide();
  }

  Future<void> _initAgora() async {
    // Request camera & mic permissions
    await [Permission.camera, Permission.microphone].request();

    // Create Agora engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: widget.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user joined channel');
          setState(() => _localUserJoined = true);
          _stopwatch.start();
          _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) {
              setState(() {
                final elapsed = _stopwatch.elapsed;
                final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
                final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
                _durationText = '$minutes:$seconds';
              });
            }
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('Remote user $remoteUid joined');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('Remote user $remoteUid left');
          setState(() => _remoteUid = null);
          // If the remote user left, end the call after a brief delay
          if (reason == UserOfflineReasonType.userOfflineQuit) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _remoteUid == null) {
                _endCall();
              }
            });
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora error: $err - $msg');
        },
      ),
    );

    // Enable video
    await _engine.enableVideo();
    await _engine.startPreview();

    // Join the channel
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _startControlsAutoHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startControlsAutoHide();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _toggleCamera() {
    setState(() => _isCameraOff = !_isCameraOff);
    _engine.muteLocalVideoStream(_isCameraOff);
  }

  void _switchCamera() {
    _engine.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  Future<void> _endCall() async {
    _stopwatch.stop();
    _durationTimer?.cancel();
    await _engine.leaveChannel();
    await _engine.release();
    widget.onCallEnded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _durationTimer?.cancel();
    _stopwatch.stop();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            // ── Remote Video (full screen) ────────────────────────────────
            _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : _buildWaitingForRemote(),

            // ── Local Video (PiP overlay) ─────────────────────────────────
            if (_localUserJoined && !_isCameraOff)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Top Bar ───────────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildTopBar(),
            ),

            // ── Bottom Controls ───────────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _showControls ? 0 : -120,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForRemote() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.videocam_outlined, color: Color(0xFF7C3AED), size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Waiting for ${widget.remoteName}...',
            style: const TextStyle(
              fontFamily: 'Figtree',
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF7C3AED),
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Call info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.remoteName,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _remoteUid != null ? Colors.greenAccent : Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _remoteUid != null ? _durationText : 'Connecting...',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Camera switch button
          _buildMiniAction(
            icon: Icons.cameraswitch_outlined,
            onTap: _switchCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: _isMuted,
            onTap: _toggleMute,
          ),
          // Camera toggle
          _buildControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: _isCameraOff ? 'Camera On' : 'Camera Off',
            isActive: _isCameraOff,
            onTap: _toggleCamera,
          ),
          // End call
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Figtree',
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: _endCall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'End',
            style: TextStyle(
              fontFamily: 'Figtree',
              color: Colors.red.shade200,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
