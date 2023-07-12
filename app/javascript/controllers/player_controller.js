import Rails from "@rails/ujs"
import { Controller } from "@hotwired/stimulus"

let timerId = null

// This class is responsible for the correct functioning of the audio player component
export default class extends Controller {
    static targets = ["player", "play", "seekSlider", "currentTimeDiv", "durationDiv", "volumeRange"]

    // when the player is created, initialise it
    initialize() {
        if (this.playerTarget.readyState > 0) {
            this.playerStartup()
        }
        else {
            this.playerTarget.addEventListener('loadedmetadata', () => {
                this.playerStartup()
            })
        }
        let raf = null
    }

    connect() {
        // Ff the player was playing, and there is a page change, request animation to
        // re-enable the update of slider
        if (!this.playerTarget.paused) {
            requestAnimationFrame(this.whilePlaying)
        }
    }

    // Update various view components when the player is in action
    whilePlaying = () => {
        this.seekSliderTarget.value = Math.floor(this.playerTarget.currentTime)
        this.currentTimeDivTarget.textContent = this.calculateTime(this.seekSliderTarget.value)
        this.setPlayerVolume()
        this.raf = requestAnimationFrame(this.whilePlaying)
        this.updateFill()
    }

    displayDuration = () => {
        this.durationDivTarget.textContent = this.calculateTime(this.playerTarget.duration)
    }

    setSliderMax = () => {
        this.seekSliderTarget.max = Math.floor(this.playerTarget.duration)
    }

    setCurrentTimeDiv = () => {
        this.currentTimeDivTarget.textContent = this.calculateTime(this.playerTarget.currentTime)
    }

    setPlayerVolume = () => {
        this.playerTarget.volume = this.volumeRangeTarget.value / 100
        this.updateVolumeFill()
    }

    // Setup the player component when initialised
    playerStartup() {
        this.seekSliderTarget.value = this.playerTarget.currentTime
        this.displayDuration()
        this.setSliderMax()
        this.setCurrentTimeDiv()
        this.setPlayerVolume()
        var playPaths = document.querySelectorAll(".playPath")
        if (!this.playerTarget.paused) {
            this.updateIcons("pause", playPaths)
        } else {
            this.updateIcons("play", playPaths)
        }

        this.updateFill()
    }

    play() {
        let playPaths = document.querySelectorAll(".playPath")

        if (this.playerTarget.paused) {
            this.playerTarget.play()
            requestAnimationFrame(this.whilePlaying)
            ahoy.track("listening:play")
            this.updateIcons("pause", playPaths)

            // Every 3 seconds during playing, send an Ajax request to save the current progress
            // (i.e., the current time of podcast listening. Thus, if the page is reloaded, progress is not lost)
            this.updateCurrentTimeValue()
        } else {
            this.playerTarget.pause()
            cancelAnimationFrame(this.raf)
            ahoy.track("listening:pause")
            this.updateIcons("play", playPaths)

            // Stop the 3 seconds save process. However, let's still save the current progress at which the listening was paused
            clearInterval(timerId)
            this.requestUpdateCurrentTime(this.playerTarget.currentTime, this.playerTarget.dataset.infoPlaylist)
        }
    }

    // When the audio file has been fully listened to (i.e., reached the end), inform the Rails controller
    playerEnd() {
        let playPaths = document.querySelectorAll(".playPath")
        this.updateIcons("play", playPaths)

        let playlist_id = document.URL.split("/").pop()

        Rails.ajax({
            url: "/playlists/:id/next".replace(":id", playlist_id),
            type: 'GET'
        })

        // stop setInterval and also make a save of current progress so far via Ajax
        clearInterval(timerId)
        this.requestUpdateCurrentTime(this.playerTarget.currentTime, this.playerTarget.dataset.infoPlaylist)
    }

    // Enable using space bar key to play and pause the player
    spaceBarPlay(e) {
        if (e.code == "Space" && document.activeElement == document.getElementById("main-body")) {
            this.play()
        }
    }

    // Scrubbing: sliding and back/forward. Back and forward is of 30 seconds
    seekSlideInput() {
        this.currentTimeDivTarget.textContent = this.calculateTime(this.seekSliderTarget.value)

        this.updateFill()

        if (!this.playerTarget.paused) {
            cancelAnimationFrame(this.raf)
        }
    }

    seekSlideChange() {
        let _type = "forward"
        let oldTime = this.playerTarget.currentTime
        if (this.seekSliderTarget.value < this.playerTarget.currentTime) {
            _type = "back";
        }
        this.playerTarget.currentTime = this.seekSliderTarget.value
        ahoy.track("listening:seek_" + _type + "_to", {
            "from": oldTime,
            "to": this.playerTarget.currentTime
        })

        this.updateFill()

        if(!this.playerTarget.paused) {
            requestAnimationFrame(this.whilePlaying)
        } else {
            document.getElementById("playerPlayBtn").click()
        }

        // Notify Rails controller of updated time
        this.requestUpdateCurrentTime(this.playerTarget.currentTime, this.playerTarget.dataset.infoPlaylist)
    }

    seekBack() {
        let currentTime = this.playerTarget.currentTime
        if (currentTime < 5) {
            this.playerTarget.currentTime = 0
        } else {
            this.playerTarget.currentTime -= 30
        }
        ahoy.track("listening:seek_back", {
            "from": currentTime,
            "to": this.playerTarget.currentTime
        })
    
        if(player.paused) {
            document.getElementById("playerPlayBtn").click()
        }
    }

    seekForward() {
        let currentTime = this.playerTarget.currentTime
        if (currentTime > (this.playerTarget.duration - 30)) {
            this.playerTarget.currentTime = this.playerTarget.duration
            document.getElementById("playerPlayBtn").click()
        } else {
            this.playerTarget.currentTime += 30
        }
        ahoy.track("listening:seek_forward", {
            "from": currentTime,
            "to": this.playerTarget.currentTime
        })
    
        if(this.playerTarget.paused) {
            document.getElementById("playerPlayBtn").click()
        }
    }

    // Volume controllers
    volumeDown() {
        let currentVolume = this.playerTarget.volume
        if (currentVolume < 0.1) {
            this.playerTarget.volume = 0
        } else {
            this.playerTarget.volume -= 0.1
        }
        this.volumeRangeTarget.value = this.playerTarget.volume * 100
        this.updateVolumeFill()

        ahoy.track("listening:volume_down", this.volumeRangeTarget.value)
    }

    volumeUp() {
        let currentVolume = this.playerTarget.volume
        if (currentVolume > 0.9) {
            this.playerTarget.volume = 1
        } else {
            this.playerTarget.volume += 0.1
        }
        this.volumeRangeTarget.value = this.playerTarget.volume * 100
        this.updateVolumeFill()

        ahoy.track("listening:volume_up", this.volumeRangeTarget.value)
    }

    volumeRange() {
        this.playerTarget.volume = this.volumeRangeTarget.value / 100
        this.updateVolumeFill()

        ahoy.track("listening:volume_to", this.volumeRangeTarget.value)
    }

    // The helper functions
    calculateTime(d) {
        if (this.playerTarget.duration >= 3600) {
            return new Date(d * 1000).toISOString().substring(11, 19)
        } else {
            return new Date(d * 1000).toISOString().substring(14, 19)
        }
    }

    updateIcons(playState, playPaths) {
        for(let j = 0; j < playPaths.length; j++) {
            if (playState == "play") {
                playPaths[j].setAttribute("d", "M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z")
            } else if (playState == "pause") {
                playPaths[j].setAttribute("d", "M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z")
            }
        }
    }

    updateCurrentTimeValue() {
        timerId = setInterval(function(playerTarget, requestUpdateCurrentTime) {
            requestUpdateCurrentTime(playerTarget.currentTime, playerTarget.dataset.infoPlaylist)
        }, 3000, this.playerTarget, this.requestUpdateCurrentTime)
    }

    requestUpdateCurrentTime(currentTime, playlistId) {
        let data = new FormData()
        data.append("playlist_id", playlistId)
        data.append("current_time", currentTime)

        Rails.ajax({
            url: '/playlists/' + playlistId + '/set_time',
            type: 'PATCH',
            data: data
        })
    }

    updateFill() {
        var fill_val = Math.floor(this.seekSliderTarget.value / this.playerTarget.duration * 100)
        this.seekSliderTarget.style.background = 'linear-gradient(to right, rgb(147 197 253) 0%, rgb(147 197 253) ' + fill_val + '%, #fff ' + fill_val + '%, white 100%)'
    }

    updateVolumeFill() {
        var fill_val = this.volumeRangeTarget.value
        this.volumeRangeTarget.style.background = 'linear-gradient(to right, rgb(147 197 253) 0%, rgb(147 197 253) ' + fill_val + '%, #fff ' + fill_val + '%, white 100%)'
    }
}
