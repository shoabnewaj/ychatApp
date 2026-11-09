// ==========================================
// JAPANESE ANIME & KIDS FAVORITES STAMPS ENGINE
// ==========================================
const STAMP_CATALOG = [
    // --- JAPANESE KIDS FAVORITES (日本のこどもに大人気) ---
    { id: 'kids_anpanman', cat: 'kids', title: 'Anpanman - Smile!', tags: 'anpanman superhero bread hero kids toddler japan', file: 'img/stamps/kids_anpanman.svg' },
    { id: 'kids_baikinman', cat: 'kids', title: 'Baikinman - Evil Laugh!', tags: 'baikinman villain anpanman germ hahihuheho kids', file: 'img/stamps/kids_baikinman.svg' },
    { id: 'kids_doraemon', cat: 'kids', title: 'Doraemon - Dorayaki!', tags: 'doraemon blue cat robot pocket dorayaki gadget kids', file: 'img/stamps/kids_doraemon.svg' },
    { id: 'kids_shinchan', cat: 'kids', title: 'Shin-chan - Mischief!', tags: 'crayon shinchan nohara shinnosuke eyebrows funny kids', file: 'img/stamps/kids_shinchan.svg' },
    { id: 'kids_chiikawa', cat: 'kids', title: 'Chiikawa - Waaah!', tags: 'chiikawa cute white tears waah nagano popular kids japan', file: 'img/stamps/kids_chiikawa.svg' },
    { id: 'kids_hachiware', cat: 'kids', title: 'Hachiware - Cheer Up!', tags: 'hachiware chiikawa blue cat nantoka nare happy kids', file: 'img/stamps/kids_hachiware.svg' },
    { id: 'kids_usagi', cat: 'kids', title: 'Usagi - Yaha!', tags: 'usagi bunny rabbit chiikawa yaha ura wild kids', file: 'img/stamps/kids_usagi.svg' },
    { id: 'kids_mario', cat: 'kids', title: 'Mario - Wahoo!', tags: 'mario super mario nintendo mustache mushroom cap wahoo kids', file: 'img/stamps/kids_mario.svg' },
    { id: 'kids_jibanyan', cat: 'kids', title: 'Jibanyan - Paws of Fury!', tags: 'jibanyan yokai watch red cat paws fury fire kids', file: 'img/stamps/kids_jibanyan.svg' },
    { id: 'kids_rilakkuma', cat: 'kids', title: 'Rilakkuma - Relax~', tags: 'rilakkuma bear relax dango sweet lazy cute san-x', file: 'img/stamps/kids_rilakkuma.svg' },

    // --- SANRIO & KAWAII CHARACTERS ---
    { id: 'kids_hellokitty', cat: 'sanrio', title: 'Hello Kitty - Bow', tags: 'hello kitty sanrio white cat red bow kawaii kids', file: 'img/stamps/kids_hellokitty.svg' },
    { id: 'kids_kuromi', cat: 'sanrio', title: 'Kuromi - Sassy Wink!', tags: 'kuromi sanrio black jester skull cheeky sassy girl', file: 'img/stamps/kids_kuromi.svg' },
    { id: 'kids_cinnamoroll', cat: 'sanrio', title: 'Cinnamoroll - Fluffy!', tags: 'cinnamoroll puppy white blue eyes cute sanrio number one', file: 'img/stamps/kids_cinnamoroll.svg' },
    { id: 'kids_pompompurin', cat: 'sanrio', title: 'Pompompurin - Pudding!', tags: 'pompompurin dog golden retriever brown beret pudding sanrio', file: 'img/stamps/kids_pompompurin.svg' },
    { id: 'kids_kirby', cat: 'sanrio', title: 'Kirby - Poyo Star!', tags: 'kirby nintendo pink star poyo cute waving kids', file: 'img/stamps/kids_kirby.svg' },
    { id: 'kids_eevee', cat: 'sanrio', title: 'Eevee - Fluffy Ears!', tags: 'eevee pokemon fluffy brown fox cute kids', file: 'img/stamps/kids_eevee.svg' },

    // --- SHONEN HEROES & ICONS ---
    { id: 'anime_naruto', cat: 'shonen', title: 'Naruto - Dattebayo!', tags: 'naruto uzumaki dattebayo leaf ninja shonen', file: 'img/stamps/anime_naruto.svg' },
    { id: 'anime_sasuke', cat: 'shonen', title: 'Sasuke - Chidori', tags: 'sasuke uchiha sharingan chidori cool ninja', file: 'img/stamps/anime_sasuke.svg' },
    { id: 'anime_kakashi', cat: 'shonen', title: 'Kakashi - Yo!', tags: 'kakashi hatake peace masked ninja sensei', file: 'img/stamps/anime_kakashi.svg' },
    { id: 'anime_luffy', cat: 'shonen', title: 'Luffy - Sugeee!', tags: 'luffy monkey d straw hat meat laugh one piece', file: 'img/stamps/anime_luffy.svg' },
    { id: 'anime_zoro', cat: 'shonen', title: 'Zoro - Lost Again?!', tags: 'zoro roronoa lost confused bandana swordsman', file: 'img/stamps/anime_zoro.svg' },
    { id: 'anime_goku_ssj', cat: 'shonen', title: 'Goku - Kamehameha!', tags: 'goku super saiyan ssj kamehameha dragon ball aura', file: 'img/stamps/anime_goku_ssj.svg' },
    { id: 'anime_vegeta', cat: 'shonen', title: 'Vegeta - Over 9000!', tags: 'vegeta saiyan pride over 9000 dragon ball smirk', file: 'img/stamps/anime_vegeta.svg' },
    { id: 'anime_tanjiro', cat: 'shonen', title: 'Tanjiro - Water Breathing', tags: 'tanjiro kamado water breathing hanafuda demon slayer', file: 'img/stamps/anime_tanjiro.svg' },
    { id: 'anime_gojo', cat: 'shonen', title: 'Gojo - Domain Expansion', tags: 'gojo satoru six eyes domain expansion jujutsu kaisen', file: 'img/stamps/anime_gojo.svg' },
    { id: 'anime_sukuna', cat: 'shonen', title: 'Sukuna - Evil Grin', tags: 'sukuna ryomen curse demon evil jujutsu kaisen', file: 'img/stamps/anime_sukuna.svg' },

    // --- ANYA & KAWAII HEROINES ---
    { id: 'anime_anya_smug', cat: 'anya', title: 'Anya - Heh (Smug)', tags: 'anya forger spy x family heh smug smirk meme', file: 'img/stamps/anime_anya_smug.svg' },
    { id: 'anime_anya_waku', cat: 'anya', title: 'Anya - Waku Waku!', tags: 'anya forger waku waku sparkle excited spy x family', file: 'img/stamps/anime_anya_waku.svg' },
    { id: 'anime_nezuko', cat: 'anya', title: 'Nezuko - Cute Muzzle', tags: 'nezuko kamado bamboo cute pink demon slayer', file: 'img/stamps/anime_nezuko.svg' },
    { id: 'anime_chopper', cat: 'anya', title: 'Chopper - Baka Yarou~', tags: 'chopper tony tony reindeer pink hat blush cute one piece', file: 'img/stamps/anime_chopper.svg' },
    { id: 'anime_pikachu_love', cat: 'anya', title: 'Pikachu - Pika Pika!', tags: 'pikachu love heart pika pika pokemon cute wink', file: 'img/stamps/anime_pikachu_love.svg' },
    { id: 'anime_heart_eyes', cat: 'anya', title: 'Anime Girl - Daisuki!', tags: 'daisuki love heart eyes kawaii blush anime girl', file: 'img/stamps/anime_heart_eyes.svg' },
    { id: 'anime_totoro', cat: 'anya', title: 'Totoro - Big Smile', tags: 'totoro my neighbor ghibli leaf smile teeth cute', file: 'img/stamps/anime_totoro.svg' },
    { id: 'anime_noface', cat: 'anya', title: 'No-Face - Ah... Ah...', tags: 'kaonashi no face spirited away ghibli gold shy', file: 'img/stamps/anime_noface.svg' },

    // --- ANIME REACTIONS & MEMES ---
    { id: 'anime_pikachu_shock', cat: 'reactions', title: 'Pikachu - Shocked Meme', tags: 'surprised pikachu shocked open mouth pokemon meme', file: 'img/stamps/anime_pikachu_shock.svg' },
    { id: 'anime_anya_shock', cat: 'reactions', title: 'Anya - Horrified Shock', tags: 'anya shock crying scream scared spy x family meme', file: 'img/stamps/anime_anya_shock.svg' },
    { id: 'anime_zenitsu', cat: 'reactions', title: 'Zenitsu - Tasukete! (Cry)', tags: 'zenitsu cry panic tears help scream demon slayer', file: 'img/stamps/anime_zenitsu.svg' },
    { id: 'anime_anger_rage', cat: 'reactions', title: 'Chibi - Baka!! (Rage)', tags: 'baka anger vein rage mad scream fangs anime', file: 'img/stamps/anime_anger_rage.svg' },
    { id: 'anime_sweatdrop', cat: 'reactions', title: 'Chibi - Ehhhhh?!', tags: 'sweatdrop ehh shocked confused awkward anime', file: 'img/stamps/anime_sweatdrop.svg' },
    { id: 'kids_psyduck', cat: 'reactions', title: 'Psyduck - Headache', tags: 'psyduck headache confused dizzy pokemon duck', file: 'img/stamps/anime_psyduck.svg' },
    { id: 'anime_cry', cat: 'reactions', title: 'Chibi - Gomen! (Tears)', tags: 'gomen sorry cry tears weeping sad chibi', file: 'img/stamps/anime_cry.svg' },
    { id: 'anime_peace', cat: 'reactions', title: 'Chibi - Peace! V', tags: 'peace victory win boy cool anime', file: 'img/stamps/anime_peace.svg' },
    { id: 'anime_sugoi', cat: 'reactions', title: 'Chibi - Sugoi!', tags: 'sugoi sparkle star eyes chibi anime girl wow', file: 'img/stamps/anime_sugoi.svg' },
    { id: 'anime_heart', cat: 'reactions', title: 'Chibi - Kawaii <3', tags: 'kawaii finger heart love kpop anime girl', file: 'img/stamps/anime_heart.svg' }
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
