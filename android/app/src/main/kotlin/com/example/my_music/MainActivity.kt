package com.example.my_music

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service needs its own activity so the media session survives the UI.
class MainActivity : AudioServiceActivity()
