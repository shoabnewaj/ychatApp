// ==========================================
// CHARACTER STAMPS & STICKERS ENGINE
// ==========================================
const STAMP_CATALOG = [
    // Cats
    { id: 'cat_love', cat: 'cat', title: 'Love You', tags: 'love heart kiss cute cat', file: 'img/stamps/cat_love.svg' },
    { id: 'cat_happy', cat: 'cat', title: 'YAY!', tags: 'happy yay joy celebrate cat', file: 'img/stamps/cat_happy.svg' },
    { id: 'cat_cry', cat: 'cat', title: 'So Sad', tags: 'sad cry tears sorry cat', file: 'img/stamps/cat_cry.svg' },
    { id: 'cat_shock', cat: 'cat', title: 'OMG!!', tags: 'omg shock what wow cat', file: 'img/stamps/cat_shock.svg' },
    { id: 'cat_thumbsup', cat: 'cat', title: 'Nice!', tags: 'nice ok yes thumbs up like cat', file: 'img/stamps/cat_thumbsup.svg' },
    { id: 'cat_sleep', cat: 'cat', title: 'Good Night', tags: 'sleep night tired zzz cat', file: 'img/stamps/cat_sleep.svg' },
    { id: 'cat_angry', cat: 'cat', title: 'Angry!', tags: 'angry hmph mad hate cat', file: 'img/stamps/cat_angry.svg' },
    { id: 'cat_dance', cat: 'cat', title: 'Party!', tags: 'party dance music happy cat', file: 'img/stamps/cat_dance.svg' },

    // Dogs
    { id: 'dog_happy', cat: 'dog', title: 'Hello!', tags: 'hello hi doge happy wag dog', file: 'img/stamps/dog_happy.svg' },
    { id: 'dog_salute', cat: 'dog', title: 'Yes Boss!', tags: 'yes boss salute respect officer dog', file: 'img/stamps/dog_salute.svg' },
    { id: 'dog_love', cat: 'dog', title: 'For You', tags: 'love heart for you cute kiss dog', file: 'img/stamps/dog_love.svg' },
    { id: 'dog_please', cat: 'dog', title: 'Please!', tags: 'please beg puppy eyes forgive dog', file: 'img/stamps/dog_please.svg' },
    { id: 'dog_cool', cat: 'dog', title: 'So Cool', tags: 'cool swag glasses boss chill dog', file: 'img/stamps/dog_cool.svg' },
    { id: 'dog_celebrate', cat: 'dog', title: 'Congrats!', tags: 'congrats party celebrate birthday dog', file: 'img/stamps/dog_celebrate.svg' },

    // Pandas
    { id: 'panda_love', cat: 'panda', title: 'Hug Me!', tags: 'hug love panda cute heart', file: 'img/stamps/panda_love.svg' },
    { id: 'panda_bamboo', cat: 'panda', title: 'Nom Nom', tags: 'food eat nom bamboo hungry panda', file: 'img/stamps/panda_bamboo.svg' },
    { id: 'panda_cry', cat: 'panda', title: 'Huhu...', tags: 'cry sad tears panda sorry', file: 'img/stamps/panda_cry.svg' },

    // Bunnies
    { id: 'bunny_heart', cat: 'bunny', title: 'So Cute!', tags: 'bunny rabbit cute love heart', file: 'img/stamps/bunny_heart.svg' },
    { id: 'bunny_carrot', cat: 'bunny', title: 'Mine!', tags: 'carrot food mine hungry rabbit bunny', file: 'img/stamps/bunny_carrot.svg' },
    { id: 'bunny_dance', cat: 'bunny', title: 'So Happy!', tags: 'happy dance joy spring flowers bunny rabbit', file: 'img/stamps/bunny_dance.svg' },

    // Anime
    { id: 'anime_sugoi', cat: 'anime', title: 'Sugoi!', tags: 'sugoi anime sparkle amazing wow chibi', file: 'img/stamps/anime_sugoi.svg' },
    { id: 'anime_peace', cat: 'anime', title: 'Peace!', tags: 'peace victory cool win boy anime', file: 'img/stamps/anime_peace.svg' },
    { id: 'anime_heart', cat: 'anime', title: 'Saranghae', tags: 'saranghae love heart kpop anime girl', file: 'img/stamps/anime_heart.svg' },
    { id: 'anime_cry', cat: 'anime', title: 'Gomen!', tags: 'gomen sorry cry tears anime girl', file: 'img/stamps/anime_cry.svg' },

    // Memes
    { id: 'meme_gigachad', cat: 'meme', title: 'Chad', tags: 'chad gigachad sigma based meme', file: 'img/stamps/meme_gigachad.svg' },
    { id: 'meme_doge', cat: 'meme', title: 'Much Wow', tags: 'doge much wow such cool meme', file: 'img/stamps/meme_doge.svg' },
    { id: 'meme_fire', cat: 'meme', title: 'This Is Fine', tags: 'fire this is fine ok coffee meme', file: 'img/stamps/meme_fire.svg' },
    { id: 'meme_troll', cat: 'meme', title: 'Problem?', tags: 'troll problem trollface funny meme', file: 'img/stamps/meme_troll.svg' },
    { id: 'meme_tea', cat: 'meme', title: 'Not My Biz', tags: 'tea kermit none of my business meme', file: 'img/stamps/meme_tea.svg' }
];

let currentStampCategory = 'all';
let chatStampSearchTimeout = null;

function toggleChatStampPicker(forceState) {
    const picker = document.getElementById("chatStampPicker");
    if (!picker) return;
    const gifPicker = document.getElementById("chatGifPicker");
    if (gifPicker) gifPicker.style.display = "none";

    const shouldShow = typeof forceState === 'boolean' ? forceState : (picker.style.display === "none" || picker.style.display === "");
    picker.style.display = shouldShow ? "flex" : "none";
    if (shouldShow) {
        renderStampGrid();
        const searchInput = document.getElementById("chatStampSearchInput");
        if (searchInput) searchInput.focus();
    }
}

function filterStamps(category, btnEl) {
    currentStampCategory = category || 'all';
    document.querySelectorAll("#stampCategoryTabs .stamp-tab-btn").forEach(function(b) {
        b.classList.remove("active");
    });
    if (btnEl) btnEl.classList.add("active");
    const searchVal = document.getElementById("chatStampSearchInput") ? document.getElementById("chatStampSearchInput").value : "";
    renderStampGrid(searchVal);
}

function debounceChatStampSearch(query) {
    clearTimeout(chatStampSearchTimeout);
    chatStampSearchTimeout = setTimeout(function() {
        renderStampGrid(query);
    }, 200);
}

function renderStampGrid(searchQuery) {
    const grid = document.getElementById("chatStampGrid");
    if (!grid) return;
    const q = (searchQuery || "").trim().toLowerCase();

    const filtered = STAMP_CATALOG.filter(function(s) {
        const matchCat = (currentStampCategory === 'all' || s.cat === currentStampCategory);
        const matchQuery = !q || s.title.toLowerCase().indexOf(q) !== -1 || s.tags.toLowerCase().indexOf(q) !== -1;
        return matchCat && matchQuery;
    });

    if (filtered.length === 0) {
        grid.innerHTML = '<div style="grid-column:span 3; text-align:center; padding:30px 10px; color:#94a3b8; font-size:12px;">No stamps found</div>';
        return;
    }

    let html = "";
    filtered.forEach(function(s) {
        const titleSafe = s.title.replace(/"/g, '&quot;');
        html += '<div class="chat-stamp-card" onclick="sendStampToFriend(\'' + s.file + '\')" title="' + titleSafe + '">' +
            '<img src="' + s.file + '" alt="' + titleSafe + '" loading="lazy">' +
            '<span>' + titleSafe + '</span>' +
        '</div>';
    });
    grid.innerHTML = html;
}

function sendStampToFriend(stampFile) {
    var friendInput = document.getElementById("targetFriendName");
    var friend = friendInput ? friendInput.value : "";
    if (friend === "None" || !friend) {
        alert("Please select a friend first to send a Stamp!");
        return;
    }
    const stampMsg = "[STAMP:" + stampFile + "]";
    if (typeof socket !== 'undefined' && socket && socket.readyState === WebSocket.OPEN) {
        socket.send("CHAT|" + friend + "|" + stampMsg);
        if (typeof displayMessage === 'function') {
            displayMessage({
                id: "temp_" + Date.now(),
                sender: typeof myName !== 'undefined' ? myName : 'Me',
                message: stampMsg,
                isRead: false,
                isEdited: false,
                isDeleted: false
            }, 'sent');
        }
        toggleChatStampPicker(false);
    } else {
        alert("Chat server connecting, please retry in a moment...");
        if (typeof initWebSocket === 'function') {
            initWebSocket();
        }
    }
}

// Close stamp picker when clicking outside
document.addEventListener("click", function(e) {
    const picker = document.getElementById("chatStampPicker");
    const stampBtn = document.getElementById("stampPickerBtn");
    if (!picker || picker.style.display === "none") return;
    if (!picker.contains(e.target) && (!stampBtn || !stampBtn.contains(e.target))) {
        picker.style.display = "none";
    }
});
