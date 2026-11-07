# Emotion library v2

> **Status:** Approved by Isa on Nov 7, 2026 (draft recommendations accepted for every open question). Wired into the app.

## 1. Summary

v1 has 98 words (14 per center). Many are abstract ("Transcendent", "Yielding"), many definitions read like dictionary entries, and two names appear in two centers (Disconnected, Reflective). v2 replaces them with 70 plain everyday words, 10 per center. Each word sits in one of five energy zones, so the Log screen can ask "how much energy, and how does it feel?" before "which word?". 31 v1 words stay as entries, Clear-minded is renamed Clear-headed, 56 v1 rows become synonyms so search still finds the old words, and 9 are dropped. The most-logged words (tired, stressed, anxious, sad, happy, calm, okay) keep their v1 centers, so radar charts don't jump on update day. The seed grid has three changes, listed in section 3, and none of the zone-tile example words moved.

## 2. Rules

1. Exactly 70 words, 10 per center, unique names. Plain words a 14-year-old would use; multi-word names are fine.
2. No near-synonyms as separate entries. Each synonym belongs to exactly one word and never equals a word's name.
3. Every center spans at least 3 zones; each zone holds 12–16 words.
4. Zone and valence agree: charged/heavy → negative, bright/calm → positive, steady → any.
5. Definitions are new, plain present tense, ≤ 70 characters, with no chakra or spiritual jargon.
6. 3–7 everyday synonyms per word. A removed v1 name becomes a synonym of its best v2 replacement wherever the meaning fits.
7. Continuity: plain words that v1 already routed to a center keep that center (tired → Sacral, stressed → Solar Plexus, calm → Heart, okay → Root, happy → Sacral, sad → Heart, angry → Solar Plexus, and other high-frequency words where possible).
8. Spread the most-logged words (Tired, Stressed, Anxious, Sad, Happy, Calm, Okay) across different centers.

Zones: **charged** = Charged & uneasy, **bright** = Bright & lively, **steady** = Steady or mixed, **heavy** = Heavy & low, **calm** = Calm & settled.

## 3. Coverage matrix

| Center | charged | bright | steady | heavy | calm | Total |
|---|---|---|---|---|---|---|
| Root | 3 | 1 | 3 | 0 | 3 | 10 |
| Sacral | 1 | 4 | 1 | 4 | 0 | 10 |
| Solar Plexus | 4 | 3 | 1 | 2 | 0 | 10 |
| Heart | 2 | 1 | 1 | 3 | 3 | 10 |
| Throat | 2 | 2 | 2 | 2 | 2 | 10 |
| Third Eye | 2 | 2 | 2 | 2 | 2 | 10 |
| Crown | 0 | 2 | 2 | 3 | 3 | 10 |
| **Total** | **14** | **15** | **12** | **16** | **13** | **70** |

Zones per center: Root 4, Sacral 4, Solar Plexus 4, Heart 5, Throat 5, Third Eye 5, Crown 4.

**Grid view**

| Center | Charged & uneasy | Bright & lively | Steady or mixed | Heavy & low | Calm & settled |
|---|---|---|---|---|---|
| Root | Anxious, Scared, Restless | Energized | Okay, Cautious, Insecure | — | Safe, Grounded, Rested |
| Sacral | Jealous | Happy, Excited, Playful, Inspired | Emotional | Tired, Bored, Numb, Guilty | — |
| Solar Plexus | Angry, Frustrated, Stressed, Overwhelmed | Confident, Proud, Motivated | Determined | Helpless, Ashamed | — |
| Heart | Hurt, Resentful | Loved | Vulnerable | Sad, Lonely, Grieving | Calm, Grateful, Caring |
| Throat | Misunderstood, Defensive | Expressive, Brave | Honest, Quiet | Withdrawn, Unheard | Understood, Relieved |
| Third Eye | Confused, Distracted | Curious, Focused | Thoughtful, Torn | Foggy, Doubtful | Clear-headed, Mindful |
| Crown | — | Hopeful, In awe | Lost, Searching | Empty, Hopeless, Disconnected | Connected, Free, Content |

### Changes from the seed grid

| # | Change | Why |
|---|---|---|
| 1 | **Relaxed** (Root, calm) is no longer an entry; it becomes a synonym of **Calm** (Heart). | It's a near-synonym of Calm (rule 2), and v1 sent "relaxed" to Heart through Peaceful (rule 7). The norms agree: relaxed and calm both have very low arousal and pleasant valence. |
| 2 | **Rested** is added to Root, calm. | It fills Root's tenth slot. It's a plain body-state word, the counterpart of Tired, and isn't a near-synonym of any other entry. |
| 3 | **Inspired** moves from Crown to **Sacral** (bright). | v1 sent "inspired" and "creative" to Sacral (both were synonyms of Creative). Sacral is "Creativity & Flow" and otherwise had no creativity word; Inspired now also holds Creative and Flowing. |
| 4 | **Content** moves from Sacral to **Crown** (calm). | This makes room for Inspired. v1 sent "content" to Heart, which is full, so Content changes center either way. In Crown it pairs with Empty: "nothing feels missing" versus "something is missing". |

Zone totals are unchanged from the seed (14 / 15 / 12 / 16 / 13). **None of the 15 zone-tile example words moved**: charged Anxious, Stressed, Angry; bright Happy, Excited, Proud; steady Okay, Torn, Thoughtful; heavy Sad, Tired, Numb; calm Calm, Safe, Grateful.

## 4. Word table

**How the norm check was done.** V and A are valence and arousal (`V.Mean.Sum`, `A.Mean.Sum`, 1–9 scales) from Warriner, Kuperman & Brysbaert (2013), *Behavior Research Methods* 45:1191–1207. They were read with WebFetch from a public copy of `Ratings_Warriner_et_al.csv` (github.com/gopalkoduri/flisound), and nothing was saved. Arousal is compared with the dataset mean (about 4.2), not with the scale midpoint:

- A ≥ 4.7 is high, which suggests charged or bright.
- A ≤ 3.7 is low, which suggests heavy or calm.
- Anything in between is near the mean, which suggests steady.

Valence is compared with about 5.0: below 4.5 is unpleasant, above 5.5 is pleasant, and in between is mixed. A Steady word passes if either its arousal or its valence is near the middle. The hand assignment wins, and each override gives the number that disagreed.

**Result:** 30 ✓, 21 overrides, 19 not in norms. The norms list lemmas, so many -ed forms such as stressed, motivated and focused are missing. Most overrides are unpleasant low-energy words whose arousal sits near the mean, because negative words tend to be rated as more arousing in these norms.

### Root

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Anxious | Root | charged | negative | Worried about what might go wrong, tense and on edge. | Worried, Nervous, Uneasy, Tense, Panicky, Edgy | ✓ | Kept from v1. Zone-tile example. |
| 2 | Scared | Root | charged | negative | Afraid of something that feels close and real right now. | Afraid, Frightened, Fearful, Terrified, Spooked, Unsafe | ✓ | v1 synonym of Anxious (Root). Fear of a real threat, versus worry about what might happen. |
| 3 | Restless | Root | charged | negative | Can't sit still or settle; your body wants to move. | Fidgety, Antsy, Jittery, Unsettled, Wired, Agitated | override: A 4.05 near mean; a body that can't settle reads charged | Kept from v1. |
| 4 | Energized | Root | bright | positive | Plenty of energy in your body and ready to go. | Energetic, Alive, Hyper, Full of energy, Radiant | not in norms | New entry. ⚠ v1 sent "energized / energetic / alive" to Solar Plexus via Radiant (see Radar impact). |
| 5 | Okay | Root | steady | neutral | Not great, not bad, just getting through the day. | Ok, Fine, Alright, Not bad, Neutral | not in norms | New entry; v1 sent okay / ok / fine / alright to Root via Stable. Zone-tile example. |
| 6 | Cautious | Root | steady | neutral | Taking it slow and watching closely before you trust or act. | Hesitant, Guarded, Careful, Wary, Watchful, On guard | override: norms read calm (A 3.57, V 6.05); as a feeling it is wary, so mixed | Kept from v1. Takes in Guarded (Heart) and Hesitant (Solar Plexus). |
| 7 | Insecure | Root | steady | negative | Unsure of yourself or of where you stand with others. | Self-conscious, Shaky, Awkward, Unsure of myself | ✓ | Kept from v1, now about self-doubt; "unsafe" moves to Scared. |
| 8 | Safe | Root | calm | positive | Protected and looked after; nothing here can hurt you. | Secure, Supported, Protected, Sheltered, Cozy | ✓ | Kept from v1. Zone-tile example. |
| 9 | Grounded | Root | calm | positive | Steady in your body, feet on the floor, hard to knock over. | Still, Settled, Stable, Rooted, Centered, Balanced, Anchored | not in norms | Kept from v1. Takes in Still, Settling, Stable, Rooted. |
| 10 | Rested | Root | calm | positive | Your body has had the sleep or the break it needed. | Refreshed, Recharged, Slept well, Restored | not in norms | **Seed change:** replaces Relaxed, which is now a synonym of Calm. |

### Sacral

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 11 | Jealous | Sacral | charged | negative | Wanting what someone else has, or scared of being replaced. | Envious, Envy, Possessive, FOMO | ✓ | New entry. ⚠ v1 sent "jealous / envious" to Solar Plexus (Inadequate) and Root (Insecure); kept in Sacral as in the seed. See open question 1. |
| 12 | Happy | Sacral | bright | positive | Feeling good and light, with smiles that come easily. | Joyful, Blissful, Glad, Cheerful, Good, Delighted, Upbeat | ✓ | v1 synonym of Joyful (Sacral). Zone-tile example. |
| 13 | Excited | Sacral | bright | positive | Buzzing about something good that's coming or happening now. | Passionate, Thrilled, Pumped, Hyped, Can't wait, Stoked | ✓ | v1 phrase → Passionate, Joyful (Sacral). Zone-tile example. |
| 14 | Playful | Sacral | bright | positive | Silly and light, up for games, jokes and messing around. | Silly, Goofy, Fun, Cheeky, Mischievous, Giggly | ✓ | Kept from v1. |
| 15 | Inspired | Sacral | bright | positive | Full of ideas and itching to make or try something new. | Creative, Flowing, Imaginative, Artistic, In the flow | ✓ | **Seed change:** moved from Crown. v1 sent "inspired" and "creative" to Sacral. |
| 16 | Emotional | Sacral | steady | neutral | Feelings sit close to the surface and spill over easily. | Sensitive, Teary, Moody, Nostalgic, Stirred up, Mood swings | ✓ | New entry. "Nostalgic" keeps v1's Sacral routing (via Yearning). |
| 17 | Tired | Sacral | heavy | negative | Low on energy; your body and mind want rest. | Sleepy, Drowsy, Wiped out, Run down, Lazy | ✓ | v1 phrase → Uninspired (Sacral). Zone-tile example. |
| 18 | Bored | Sacral | heavy | negative | Nothing grabs your interest and the time drags. | Uninspired, Unmotivated, Meh, Blah, Uninterested | ✓ | v1 synonym of Uninspired (Sacral). |
| 19 | Numb | Sacral | heavy | negative | Feelings are switched off; nothing really gets through. | Blank, Flat, Shut down, Apathetic, Unfeeling | ✓ | Kept from v1. Zone-tile example. |
| 20 | Guilty | Sacral | heavy | negative | Bad about something you did and wishing you could undo it. | Regretful, Remorseful, At fault, To blame | override: A 4.65 near mean; guilt lingers as a low, heavy feeling | Kept from v1. |

### Solar Plexus

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 21 | Angry | Solar Plexus | charged | negative | Hot and fired up at someone or something that crossed a line. | Mad, Furious, Livid, Fuming, Raging | ✓ | v1 synonym of Frustrated (Solar Plexus). Zone-tile example. |
| 22 | Frustrated | Solar Plexus | charged | negative | Blocked from what you want, and it keeps not working. | Annoyed, Irritated, Irritable, Fed up, Aggravated, Sick of it | ✓ | Kept from v1. |
| 23 | Stressed | Solar Plexus | charged | negative | Under pressure, with too much riding on you and too little time. | Stressed out, Under pressure, Pressured, Frazzled | not in norms | v1 phrase → Overwhelmed (Solar Plexus). Zone-tile example. |
| 24 | Overwhelmed | Solar Plexus | charged | negative | Too much at once; you can't keep up or take any more in. | Swamped, Drowning, Burnt out, Burned out, Stretched thin, Overloaded, Snowed under | ✓ | Kept from v1. |
| 25 | Confident | Solar Plexus | bright | positive | Sure of yourself and what you can do. | Empowered, Capable, Bold, Assured, Self-assured, Sure of myself | override: A 4.62 just under the high band; an active, can-do state | Kept from v1. Takes in Empowered, Capable, Bold, Assured. |
| 26 | Proud | Solar Plexus | bright | positive | Pleased with something you did or someone you care about. | Accomplished, Pleased with myself, Chuffed, Successful | ✓ | v1 phrase → Confident (Solar Plexus). Zone-tile example. |
| 27 | Motivated | Solar Plexus | bright | positive | Keen to get going and get things done. | Ambitious, Driven, Eager, Productive, Keen | not in norms | v1 synonym of Driven (Solar Plexus). |
| 28 | Determined | Solar Plexus | steady | neutral | Set on doing it, even when it's hard or slow. | Persistent, Stubborn, Committed, Won't give up | not in norms | Kept from v1, still neutral. |
| 29 | Helpless | Solar Plexus | heavy | negative | Unable to change what's happening, no matter what you try. | Powerless, Trapped, Defeated, Out of my depth | override: A 4.91 suggests charged; as a check-in it reads defeated and drained | v1 synonym of Powerless (Solar Plexus). |
| 30 | Ashamed | Solar Plexus | heavy | negative | Wanting to hide because you feel bad about who you are. | Inadequate, Embarrassed, Humiliated, Not good enough, Worthless, Useless | override: A 5.65 suggests charged; the lasting feeling is shrinking and hiding | New entry. ⚠ v1 put "ashamed / shame / embarrassed" under Guilty (Sacral); kept in Solar Plexus as in the seed (shame is about self-worth). |

### Heart

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 31 | Hurt | Heart | charged | negative | Stung by something someone said or did. | Wounded, Stung, Betrayed, Let down, Offended | ✓ | Kept from v1. |
| 32 | Resentful | Heart | charged | negative | Still angry about something unfair that was done to you. | Bitter, Resentment, Grudge, Not fair, Hard done by | override: A 4.35 near mean; simmering anger, grouped with the charged words | v1 phrase → Hurt (Heart), Frustrated. |
| 33 | Loved | Heart | bright | positive | Wanted and cared about, just as you are. | Accepted, Cared for, Adored, Appreciated, Included, Valued | ✓ | v1 phrase → Accepted, Loving (Heart). |
| 34 | Vulnerable | Heart | steady | neutral | Exposed and unguarded, with your feelings out in the open. | Exposed, Raw, Fragile, Unguarded, Defenseless | ✓ | Kept from v1, still neutral. |
| 35 | Sad | Heart | heavy | negative | Low and heavy-hearted; you might feel like crying. | Unhappy, Upset, Down, Blue, Gloomy, Miserable | ✓ | v1 synonym of Lonely and Grieving (Heart). Zone-tile example. |
| 36 | Lonely | Heart | heavy | negative | Wanting company or closeness that isn't there right now. | Yearning, Alone, Lonesome, Isolated, Left out, Abandoned | override: A 4.37 near mean; an aching, low feeling | Kept from v1. |
| 37 | Grieving | Heart | heavy | negative | Aching over someone or something you've lost. | Grief, Mourning, Heartbroken, Devastated, Sorrow | override: A 5.05 suggests charged (acute grief); day to day it is heavy | Kept from v1. |
| 38 | Calm | Heart | calm | positive | Settled and unhurried; nothing is pulling at you. | Peaceful, Relaxed, Chill, At peace, Serene, Tranquil, Mellow | ✓ | v1 phrase → Peaceful (Heart). Now also holds Relaxed (seed change). Zone-tile example. |
| 39 | Grateful | Heart | calm | positive | Thankful for something or someone good in your life. | Thankful, Appreciative, Blessed, Lucky | override: A 4.29 near mean; a warm, settled feeling | Kept from v1. Zone-tile example. |
| 40 | Caring | Heart | calm | positive | Warm toward someone and wanting good things for them. | Tender, Loving, Compassionate, Kind, Affectionate, Sympathetic, Empathetic | not in norms | v1 synonym of Loving and Compassionate (Heart). |

### Throat

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 41 | Misunderstood | Throat | charged | negative | People get you wrong, even when you try to explain. | Misjudged, Misread, Judged, Misinterpreted | not in norms | Kept from v1. |
| 42 | Defensive | Throat | charged | negative | Feeling attacked and quick to push back or explain yourself. | Attacked, Prickly, Touchy, Argumentative | override: near mean on both (A 4.28, V 4.65); as a feeling it is tense and unpleasant | New entry. ⚠ v1 synonym of Guarded (Heart); rarely logged. |
| 43 | Expressive | Throat | bright | positive | Words and feelings come out of you easily. | Articulate, Talkative, Chatty, Vocal, Outspoken | ✓ | Kept from v1. |
| 44 | Brave | Throat | bright | positive | Scared maybe, but you speak up or step forward anyway. | Courageous, Daring, Fearless, Gutsy, Spoke up | ✓ | New entry. ⚠ v1 synonym of Bold (Solar Plexus). See open question 9. |
| 45 | Honest | Throat | steady | neutral | Being real about what you think and feel, even when it's hard. | Authentic, Truthful, Genuine, Real, Upfront, Sincere | ✓ | Kept from v1. |
| 46 | Quiet | Throat | steady | neutral | Not in the mood to talk; happy to listen and take things in. | Listening, Shy, Reserved, Introverted, Silent | override: norms read calm (A 1.95, V 6.47); a quiet day can be good or flat | v1 synonym of Still (Root) and Withdrawn (Throat), but ignored in free text. |
| 47 | Withdrawn | Throat | heavy | negative | Pulling back from people and keeping to yourself. | Closed, Closed off, Distant, Antisocial, Hiding, Keeping to myself | not in norms | Kept from v1. |
| 48 | Unheard | Throat | heavy | negative | No one is listening, or the words just won't come out. | Silenced, Constricted, Ignored, Muted, Bottled up, Talked over | ✓ | v1 phrase → Silenced, Misunderstood (Throat). |
| 49 | Understood | Throat | calm | positive | Someone gets what you mean and how you feel. | Heard, Seen, Listened to, Validated, Acknowledged | not in norms | Kept from v1. |
| 50 | Relieved | Throat | calm | positive | Lighter now that something hard is over or finally said. | Relief, Off my chest, Weight lifted, Phew | not in norms | New entry. ⚠ v1 phrase → Peaceful (Heart). See open question 2. |

### Third Eye

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 51 | Confused | Third Eye | charged | negative | Can't make sense of what's going on or what to think. | Puzzled, Baffled, Bewildered, Mixed up, Perplexed, Disoriented | override: A 4.28 near mean; kept with the busy, unsettled words | Kept from v1. |
| 52 | Distracted | Third Eye | charged | negative | Your attention keeps jumping and won't stay on one thing. | Scattered, Unfocused, Sidetracked, Disorganized, All over the place | not in norms | v1 synonym of Scattered (Third Eye). |
| 53 | Curious | Third Eye | bright | positive | Wanting to find out more, explore and ask questions. | Wondering, Interested, Intrigued, Fascinated, Inquisitive, Open-minded | ✓ | Kept from v1. |
| 54 | Focused | Third Eye | bright | positive | Locked in on one thing while the rest fades out. | Concentrating, Locked in, Absorbed, Dialed in, Attentive | not in norms | Kept from v1. |
| 55 | Thoughtful | Third Eye | steady | neutral | Turning something over in your mind, taking your time. | Reflective, Processing, Contemplative, Pensive, Deep in thought, Pondering | override: norms read calm (A 2.55, V 7.26), as in "considerate"; here it means mulling things over | v1 synonym of Contemplative (Third Eye) and Reflective. Zone-tile example. |
| 56 | Torn | Third Eye | steady | negative | Pulled two ways at once and unsure which to follow. | Conflicted, Indecisive, Mixed feelings, On the fence, Ambivalent, Divided | not in norms | New entry. Zone-tile example. |
| 57 | Foggy | Third Eye | heavy | negative | Slow, cloudy thinking, like your head is full of cotton. | Brain fog, Hazy, Muddled, Fuzzy, Cloudy, Spaced out, Zoned out | override: V 4.65 near mean (the weather sense); brain fog is unpleasant | Kept from v1. |
| 58 | Doubtful | Third Eye | heavy | negative | Not sure something is true, or that it will work out. | Unsure, Uncertain, Skeptical, Second-guessing, Unconvinced | override: A 4.55 near mean; doubt sinks rather than revs | Kept from v1. |
| 59 | Clear-headed | Third Eye | calm | positive | Thinking straight and seeing what matters. | Clear-minded, Clear, Insightful, Perceptive, Lucid, Level-headed, Sharp | not in norms | Renamed from Clear-minded. |
| 60 | Mindful | Third Eye | calm | positive | Fully here, noticing what's happening without rushing. | Present, Aware, Observant, Here and now | override: A 6.0 suggests bright; in a check-in it means calmly present | v1 synonym of Present (Root) and Aware (Third Eye). |

### Crown

| # | Word | Center | Zone | Valence | Definition | Synonyms | Norm check | Notes |
|---|---|---|---|---|---|---|---|---|
| 61 | Hopeful | Crown | bright | positive | Things could get better, and you're looking forward to it. | Optimistic, Encouraged, Positive, Looking forward | ✓ | v1 phrase → Open (Crown). |
| 62 | In awe | Crown | bright | positive | Amazed by something so big or beautiful it stops you. | Transcendent, Awe, Amazed, Awestruck, Blown away, Mind-blown | override: rated as "awe", A 3.83 near mean; "blown away" is lively | v1 phrase "awe" → Transcendent (Crown). |
| 63 | Lost | Crown | steady | negative | Unsure where you're headed or what you want from life. | Directionless, Aimless, Adrift, Off track | override: A 5.11 suggests charged (lost in a place); lost in life is mixed | v1 phrase → Searching (Crown), Confused. |
| 64 | Searching | Crown | steady | neutral | Looking for answers, meaning, or where you fit. | Seeking, Questioning, Exploring, Figuring it out, Soul-searching | not in norms | Kept from v1. |
| 65 | Empty | Crown | heavy | negative | Hollow inside, like something important is missing. | Meaningless, Hollow, Pointless, Void, Purposeless | ✓ | v1 synonym of Meaningless and Hollow (Crown). |
| 66 | Hopeless | Crown | heavy | negative | Sure things won't get better, so why even try. | Cynical, Despair, Pessimistic, Jaded, Giving up, No hope | override: A 4.52 near mean; a defeated, low feeling | v1 phrase → Powerless (Solar Plexus), Meaningless (Crown). |
| 67 | Disconnected | Crown | heavy | negative | Cut off from people, from yourself, or from the world. | Detached, Cut off, Dissociated, Out of touch | not in norms | Kept from v1. v1's Root copy merges here (see mapping). |
| 68 | Connected | Crown | calm | positive | Part of something bigger, and your life feels like it matters. | Purposeful, Unified, Belonging, In tune, Part of something | not in norms | Kept from v1. |
| 69 | Free | Crown | calm | positive | Nothing is holding you back; you can just be yourself. | Open, Liberated, Carefree, Letting go, Unstuck | override: A 5.38 suggests bright; kept calm in the "unburdened" sense (open question 10) | New entry. |
| 70 | Content | Crown | calm | positive | Satisfied with things as they are; nothing feels missing. | Whole, Satisfied, Fulfilled, Complete | ✓ | **Seed change:** moved from Sacral. ⚠ v1 phrase → Peaceful (Heart), so it changes center either way. |

## 5. v1 → v2 mapping

Old check-ins keep their stored name and center forever. Valence for removed or renamed words still resolves through the frozen `v1Valence` table, so nothing in history is rewritten. This table only decides where *new* logs of these words land.

Totals: 32 rows kept (31 words, because Disconnected's two rows merge), 1 renamed, 56 now synonyms, 9 removed. **Only one kept word changes center: Disconnected's Root copy**, which merges into the single Crown entry.

| v1 word | v1 center | v1 valence | v2 outcome | v2 center | Note |
|---|---|---|---|---|---|
| Anxious | Root | negative | kept | Root | |
| Insecure | Root | negative | kept | Root | Now about self-doubt; "unsafe" moves to Scared. |
| Disconnected | Root | negative | kept (merged) | Crown | ⚠ **Kept word changes center.** v2 has one Disconnected, in Crown. Old Root entries keep their stored center. |
| Restless | Root | negative | kept | Root | |
| Cautious | Root | neutral | kept | Root | |
| Still | Root | neutral | now a synonym of Grounded | Root | Cue-gated, so "I'm still tired" doesn't match. |
| Settling | Root | neutral | now a synonym of Grounded (as Settled) | Root | Listed as "Settled"; the matcher's stemmer and search both treat settling and settled as one word. |
| Present | Root | neutral | now a synonym of Mindful | Third Eye | ⚠ Center change; rarely logged. |
| Grounded | Root | positive | kept | Root | |
| Secure | Root | positive | now a synonym of Safe | Root | |
| Stable | Root | positive | now a synonym of Grounded | Root | |
| Safe | Root | positive | kept | Root | |
| Supported | Root | positive | now a synonym of Safe | Root | |
| Rooted | Root | positive | now a synonym of Grounded | Root | |
| Stuck | Sacral | negative | removed | — | A new everyday phrase `stuck` → Bored, Frustrated keeps it findable and keeps one target in Sacral. |
| Numb | Sacral | negative | kept | Sacral | |
| Guilty | Sacral | negative | kept | Sacral | |
| Uninspired | Sacral | negative | now a synonym of Bored | Sacral | |
| Stirring | Sacral | neutral | removed | — | No plain equivalent; Emotional lists "stirred up". |
| Yearning | Sacral | neutral | now a synonym of Lonely | Heart | ⚠ Center change; rarely logged. |
| Yielding | Sacral | neutral | removed | — | The phrase `let go` now points at Free. |
| Fluid | Sacral | neutral | removed | — | Not an everyday feeling word. |
| Playful | Sacral | positive | kept | Sacral | |
| Creative | Sacral | positive | now a synonym of Inspired | Sacral | |
| Passionate | Sacral | positive | now a synonym of Excited | Sacral | |
| Flowing | Sacral | positive | now a synonym of Inspired | Sacral | |
| Joyful | Sacral | positive | now a synonym of Happy | Sacral | |
| Sensual | Sacral | positive | removed | — | Not suited to an everyday list for ages 14+. |
| Powerless | Solar Plexus | negative | now a synonym of Helpless | Solar Plexus | |
| Inadequate | Solar Plexus | negative | now a synonym of Ashamed | Solar Plexus | |
| Frustrated | Solar Plexus | negative | kept | Solar Plexus | |
| Overwhelmed | Solar Plexus | negative | kept | Solar Plexus | |
| Hesitant | Solar Plexus | neutral | now a synonym of Cautious | Root | ⚠ Center change; rarely logged. |
| Ambitious | Solar Plexus | neutral | now a synonym of Motivated | Solar Plexus | |
| Driven | Solar Plexus | neutral | now a synonym of Motivated | Solar Plexus | Cue-gated. |
| Determined | Solar Plexus | neutral | kept | Solar Plexus | |
| Confident | Solar Plexus | positive | kept | Solar Plexus | |
| Empowered | Solar Plexus | positive | now a synonym of Confident | Solar Plexus | |
| Capable | Solar Plexus | positive | now a synonym of Confident | Solar Plexus | |
| Bold | Solar Plexus | positive | now a synonym of Confident | Solar Plexus | Kept in Solar Plexus rather than under Brave, so "bold" doesn't move. |
| Radiant | Solar Plexus | positive | now a synonym of Energized | Root | ⚠ Center change. v1 used Radiant as the target for energized / energetic / alive. |
| Assured | Solar Plexus | positive | now a synonym of Confident | Solar Plexus | |
| Lonely | Heart | negative | kept | Heart | |
| Closed | Heart | negative | now a synonym of Withdrawn | Throat | ⚠ Center change; rarely logged. |
| Hurt | Heart | negative | kept | Heart | |
| Grieving | Heart | negative | kept | Heart | |
| Guarded | Heart | neutral | now a synonym of Cautious | Root | ⚠ Center change; rarely logged. |
| Receptive | Heart | neutral | removed | — | Closest is Curious ("open-minded"). |
| Tender | Heart | neutral | now a synonym of Caring | Heart | |
| Vulnerable | Heart | neutral | kept | Heart | |
| Loving | Heart | positive | now a synonym of Caring | Heart | |
| Compassionate | Heart | positive | now a synonym of Caring | Heart | |
| Grateful | Heart | positive | kept | Heart | |
| Accepted | Heart | positive | now a synonym of Loved | Heart | Cue-gated. |
| Forgiving | Heart | positive | removed | — | The phrase `forgive` now points at Caring. |
| Peaceful | Heart | positive | now a synonym of Calm | Heart | |
| Misunderstood | Throat | negative | kept | Throat | |
| Silenced | Throat | negative | now a synonym of Unheard | Throat | |
| Constricted | Throat | negative | now a synonym of Unheard | Throat | |
| Withdrawn | Throat | negative | kept | Throat | |
| Reflective | Throat | neutral | now a synonym of Thoughtful | Third Eye | ⚠ Center change; rarely logged. |
| Listening | Throat | neutral | now a synonym of Quiet | Throat | Cue-gated. |
| Processing | Throat | neutral | now a synonym of Thoughtful | Third Eye | ⚠ Center change; rarely logged. |
| Honest | Throat | neutral | kept | Throat | |
| Expressive | Throat | positive | kept | Throat | |
| Authentic | Throat | positive | now a synonym of Honest | Throat | |
| Heard | Throat | positive | now a synonym of Understood | Throat | Cue-gated. |
| Understood | Throat | positive | kept | Throat | |
| Clear | Throat | positive | now a synonym of Clear-headed | Third Eye | ⚠ Center change; rarely logged. |
| Articulate | Throat | positive | now a synonym of Expressive | Throat | |
| Confused | Third Eye | negative | kept | Third Eye | |
| Scattered | Third Eye | negative | now a synonym of Distracted | Third Eye | |
| Doubtful | Third Eye | negative | kept | Third Eye | |
| Foggy | Third Eye | negative | kept | Third Eye | |
| Contemplative | Third Eye | neutral | now a synonym of Thoughtful | Third Eye | |
| Observant | Third Eye | neutral | now a synonym of Mindful | Third Eye | |
| Wondering | Third Eye | neutral | now a synonym of Curious | Third Eye | |
| Curious | Third Eye | neutral | kept | Third Eye | ⚠ Valence changes from neutral to positive (bright). `valence(forStoredName:center:)` tries the current library first, so old Curious check-ins will also start counting as positive in the trend (open question 14). |
| Intuitive | Third Eye | positive | removed | — | No plain v2 equivalent (open question 13). |
| Aware | Third Eye | positive | now a synonym of Mindful | Third Eye | Ignored in free text ("I'm aware that…"); search still finds it. |
| Perceptive | Third Eye | positive | now a synonym of Clear-headed | Third Eye | |
| Insightful | Third Eye | positive | now a synonym of Clear-headed | Third Eye | |
| Clear-minded | Third Eye | positive | renamed to Clear-headed | Third Eye | The old name stays as a synonym. |
| Focused | Third Eye | positive | kept | Third Eye | |
| Meaningless | Crown | negative | now a synonym of Empty | Crown | |
| Disconnected | Crown | negative | kept | Crown | |
| Cynical | Crown | negative | now a synonym of Hopeless | Crown | |
| Hollow | Crown | negative | now a synonym of Empty | Crown | |
| Searching | Crown | neutral | kept | Crown | |
| Surrendering | Crown | neutral | removed | — | "Letting go" (a synonym) and the phrase `let go` now point at Free. |
| Open | Crown | neutral | now a synonym of Free | Crown | Cue-gated ("I feel open"). |
| Reflective | Crown | neutral | now a synonym of Thoughtful | Third Eye | ⚠ Center change; rarely logged. |
| Connected | Crown | positive | kept | Crown | |
| Whole | Crown | positive | now a synonym of Content | Crown | |
| Purposeful | Crown | positive | now a synonym of Connected | Crown | |
| Transcendent | Crown | positive | now a synonym of In awe | Crown | |
| Blissful | Crown | positive | now a synonym of Happy | Sacral | ⚠ Center change; rarely logged. |
| Unified | Crown | positive | now a synonym of Connected | Crown | |

## 6. Matcher retarget table

### 6.1 `everydayPhrases`

**delete** means the key now equals a v2 name or synonym, so the lexicon already covers it. There are 187 v1 keys: 65 are deleted and 122 are kept or retargeted. 3 keys are new.

| phrase | v1 targets | v2 targets | note |
|---|---|---|---|
| `anxiety` | Anxious | Anxious | |
| `panic` | Anxious | Anxious | |
| `panicking` | Anxious | Anxious | |
| `panicked` | Anxious | Anxious | |
| `panicky` | Anxious | **delete** | Now a synonym of Anxious. |
| `on edge` | Anxious, Restless | Anxious, Restless | Kept as a phrase so both targets survive. |
| `freaking out` | Anxious | Anxious, Scared | |
| `freaked out` | Anxious | Anxious, Scared | |
| `dread` | Anxious | Anxious | |
| `dreading` | Anxious | Anxious | |
| `fear` | Anxious | Scared | |
| `terrified` | Anxious | **delete** | Now a synonym of Scared. |
| `scary` | Anxious | Scared | |
| `overthinking` | Anxious, Scattered | Anxious, Distracted | |
| `spiraling` | Anxious, Overwhelmed | Anxious, Overwhelmed | |
| `spiralling` | Anxious, Overwhelmed | Anxious, Overwhelmed | |
| `threatened` | Insecure | Scared, Insecure | |
| `not safe` | Insecure | Scared | Insecure is now about self-doubt. |
| `don't feel safe` | Insecure | Scared | |
| `jittery` | Restless | **delete** | Now a synonym of Restless. |
| `can't relax` | Restless | Restless | |
| `can't sit still` | Restless | Restless | |
| `can't sleep` | Restless, Anxious | Restless, Anxious | |
| `impatient` | Restless, Frustrated | Restless, Frustrated | |
| `stressed` | Overwhelmed | **delete** | Now a v2 name. |
| `stressed out` | Overwhelmed, Anxious | **delete** | Now a synonym of Stressed (the Anxious second target is dropped). |
| `stress` | Overwhelmed | Stressed | |
| `stressful` | Overwhelmed | Stressed | |
| `burnt out` | Overwhelmed | **delete** | Now a synonym of Overwhelmed. |
| `burned out` | Overwhelmed | **delete** | Now a synonym of Overwhelmed. |
| `burnout` | Overwhelmed | Overwhelmed | |
| `too much` | Overwhelmed | Overwhelmed | |
| `exhausted` | Overwhelmed | Tired, Overwhelmed | Adds the plain meaning and keeps v1's Solar Plexus target. |
| `drained` | Overwhelmed | Tired, Overwhelmed | Same as above. |
| `worn out` | Overwhelmed | Tired, Overwhelmed | Same as above. |
| `stretched thin` | Overwhelmed | **delete** | Now a synonym of Overwhelmed. |
| `under pressure` | Overwhelmed | **delete** | Now a synonym of Stressed. |
| `overstimulated` | Overwhelmed, Scattered | Overwhelmed, Distracted | |
| `not okay` | Overwhelmed | Sad, Overwhelmed | Adds Sad (open question 12). |
| `not ok` | Overwhelmed | Sad, Overwhelmed | |
| `not alright` | Overwhelmed | Sad, Overwhelmed | |
| `can't cope` | Overwhelmed, Powerless | Overwhelmed, Helpless | |
| `can't handle` | Overwhelmed, Powerless | Overwhelmed, Helpless | |
| `out of control` | Powerless, Overwhelmed | Helpless, Overwhelmed | |
| `tired` | Uninspired | **delete** | Now a v2 name. |
| `meh` | Uninspired | **delete** | Now a synonym of Bored. |
| `blah` | Uninspired | **delete** | Now a synonym of Bored. |
| `lazy` | Uninspired | **delete** | Now a synonym of Tired. |
| `sluggish` | Uninspired, Foggy | Tired, Foggy | |
| `unproductive` | Uninspired | Bored | |
| `no energy` | Uninspired, Overwhelmed | Tired | |
| `no motivation` | Uninspired | Bored | |
| `feeling down` | Hollow, Uninspired | Sad | v1 had no Sad word. ⚠ Moves from Crown and Sacral to Heart. |
| `feel down` | Hollow, Uninspired | Sad | Same as above. |
| `feeling low` | Hollow, Uninspired | Sad | Same as above. |
| `feeling blue` | Lonely | Sad | Needed because "blue" is ignored in free text. |
| `depressed` | Hollow, Uninspired | Sad, Empty | Keeps one Crown target. |
| `can't feel anything` | Numb | Numb | |
| `feel nothing` | Numb | Numb | |
| `don't care` | Numb, Uninspired | Numb, Bored | |
| `dead inside` | Numb, Hollow | Numb, Empty | |
| `empty inside` | Hollow | Empty | Kept: the phrase skips the cue rule on "empty". |
| `not myself` | Disconnected | Disconnected | |
| `nothing matters` | Meaningless | Empty | |
| `what's the point` | Meaningless | Hopeless, Empty | |
| `no purpose` | Meaningless | Empty | |
| `hopeless` | Powerless, Meaningless | **delete** | Now a v2 name. |
| `sadness` | Lonely, Grieving | Sad | |
| `crying` | Grieving, Hurt | Sad | |
| `cried` | Grieving, Hurt | Sad | |
| `tears` | Grieving, Hurt | Sad | |
| `can't stop crying` | Grieving, Hurt | Sad | |
| `heartbreak` | Grieving | Grieving | |
| `loss` | Grieving | Grieving | |
| `hurting` | Hurt | Hurt | Kept: the stemmer doesn't reach 4-letter "hurt". |
| `hurts` | Hurt | Hurt | Same as above. |
| `broken` | Hurt | Hurt | Cue-gated. |
| `pain` | Hurt | Hurt | |
| `bitter` | Cynical, Hurt | **delete** | Now a synonym of Resentful. |
| `resentful` | Hurt, Frustrated | **delete** | Now a v2 name. |
| `resentment` | Hurt, Frustrated | **delete** | Now a synonym of Resentful. |
| `rejected` | Lonely, Hurt | Hurt, Lonely | |
| `unloved` | Lonely, Hurt | Lonely, Hurt | |
| `unwanted` | Lonely, Hurt | Lonely, Hurt | |
| `left out` | Lonely, Hurt | **delete** | Now a synonym of Lonely. |
| `excluded` | Lonely, Hurt | Lonely, Hurt | |
| `no one cares` | Lonely | Lonely | |
| `nobody cares` | Lonely | Lonely | |
| `homesick` | Yearning, Lonely | Lonely, Sad | ⚠ Loses its Sacral share. |
| `nostalgic` | Yearning | **delete** | Now a synonym of Emotional (stays in Sacral). |
| `miss` | Yearning | Lonely, Sad | ⚠ Moves from Sacral to Heart. |
| `missing` | Yearning | Lonely, Sad | Same as above. |
| `anger` | Frustrated | Angry | |
| `rage` | Frustrated | Angry | |
| `hate` | Frustrated | Angry, Frustrated | |
| `pissed` | Frustrated | Angry | |
| `pissed off` | Frustrated | Angry | |
| `irritable` | Frustrated | **delete** | Now a synonym of Frustrated. |
| `fed up` | Frustrated | **delete** | Now a synonym of Frustrated. |
| `not good enough` | Inadequate | **delete** | Now a synonym of Ashamed. |
| `useless` | Inadequate | **delete** | Now a synonym of Ashamed. |
| `worthless` | Inadequate | **delete** | Now a synonym of Ashamed. |
| `failure` | Inadequate | Ashamed | |
| `imposter` | Inadequate, Doubtful | Insecure, Doubtful | ⚠ Moves from Solar Plexus to Root. |
| `impostor` | Inadequate, Doubtful | Insecure, Doubtful | Same as above. |
| `self doubt` | Doubtful, Inadequate | Doubtful, Insecure | |
| `hate myself` | Inadequate, Guilty | Ashamed, Guilty | |
| `jealous` | Inadequate, Insecure | **delete** | Now a v2 name. |
| `envious` | Inadequate, Insecure | **delete** | Now a synonym of Jealous. |
| `guilt` | Guilty | Guilty | |
| `shame` | Guilty | Ashamed | ⚠ Moves from Sacral to Solar Plexus. |
| `embarrassed` | Guilty | **delete** | Now a synonym of Ashamed. ⚠ Moves from Sacral to Solar Plexus. |
| `regret` | Guilty | Guilty | |
| `ignored` | Silenced, Misunderstood | **delete** | Now a synonym of Unheard. |
| `unheard` | Silenced, Misunderstood | **delete** | Now a v2 name. |
| `not heard` | Silenced, Misunderstood | Unheard | |
| `not understood` | Misunderstood | Misunderstood | |
| `nobody listens` | Silenced, Misunderstood | Unheard | |
| `no one listens` | Silenced, Misunderstood | Unheard | |
| `judged` | Misunderstood | **delete** | Now a synonym of Misunderstood. |
| `criticized` | Misunderstood, Hurt | Defensive, Hurt | |
| `bottled up` | Constricted | **delete** | Now a synonym of Unheard. |
| `holding back` | Constricted | Unheard | |
| `choked up` | Constricted | Emotional, Unheard | |
| `lump in my throat` | Constricted | Unheard, Sad | |
| `tight chest` | Constricted, Anxious | Anxious | |
| `shy` | Withdrawn | **delete** | Now a synonym of Quiet. |
| `antisocial` | Withdrawn | **delete** | Now a synonym of Withdrawn. |
| `want to be alone` | Withdrawn | Withdrawn | |
| `disappear` | Withdrawn, Hollow | Withdrawn, Empty | |
| `invisible` | Withdrawn, Hollow | Unheard, Lonely | |
| `hiding` | Withdrawn | **delete** | Now a synonym of Withdrawn. |
| `lost` | Searching, Confused | **delete** | Now a v2 name (cue-gated). |
| `confusion` | Confused | Confused | |
| `can't focus` | Scattered, Foggy | Distracted, Foggy | |
| `can't concentrate` | Scattered, Foggy | Distracted, Foggy | |
| `can't think` | Foggy | Foggy | |
| `brain fog` | Foggy | **delete** | Now a synonym of Foggy. |
| `indecisive` | Hesitant, Doubtful | **delete** | Now a synonym of Torn. |
| `fascinated` | Curious | **delete** | Now a synonym of Curious. |
| `in the zone` | Focused, Flowing | Focused, Inspired | |
| `calm` | Peaceful | **delete** | Now a v2 name. |
| `relaxed` | Peaceful | **delete** | Now a synonym of Calm. |
| `chill` | Peaceful | **delete** | Now a synonym of Calm. |
| `content` | Peaceful | **delete** | Now a v2 name (cue-gated). ⚠ Moves from Heart to Crown. |
| `at peace` | Peaceful | **delete** | Now a synonym of Calm. |
| `peace` | Peaceful | Calm | |
| `relieved` | Peaceful | **delete** | Now a v2 name. ⚠ Moves from Heart to Throat. |
| `relief` | Peaceful | **delete** | Now a synonym of Relieved. |
| `okay` | Stable | **delete** | Now a v2 name (cue-gated). |
| `ok` | Stable | **delete** | Now a synonym of Okay. |
| `alright` | Stable | **delete** | Now a synonym of Okay. |
| `fine` | Stable | **delete** | Now a synonym of Okay. |
| `great` | Joyful | Happy | |
| `amazing` | Joyful | Happy | |
| `awesome` | Joyful | Happy | |
| `wonderful` | Joyful | Happy | |
| `fantastic` | Joyful | Happy | |
| `excited` | Passionate, Joyful | **delete** | Now a v2 name. |
| `thrilled` | Joyful, Passionate | **delete** | Now a synonym of Excited. |
| `silly` | Playful | **delete** | Now a synonym of Playful. |
| `goofy` | Playful | **delete** | Now a synonym of Playful. |
| `energized` | Radiant | **delete** | Now a v2 name. ⚠ Moves from Solar Plexus to Root. |
| `energetic` | Radiant | **delete** | Now a synonym of Energized. |
| `alive` | Radiant | **delete** | Now a synonym of Energized (cue-gated). |
| `hopeful` | Open | **delete** | Now a v2 name. |
| `optimistic` | Open | **delete** | Now a synonym of Hopeful. |
| `proud` | Confident | **delete** | Now a v2 name. |
| `accomplished` | Capable, Confident | **delete** | Now a synonym of Proud. |
| `productive` | Driven, Capable | **delete** | Now a synonym of Motivated. |
| `powerful` | Empowered | Confident | |
| `in control` | Empowered, Assured | Confident | |
| `courage` | Bold | Brave | ⚠ Moves from Solar Plexus to Throat. |
| `love` | Loving | Caring | |
| `in love` | Loving, Passionate | Caring, Excited | Keeps v1's Heart and Sacral pair. |
| `loved` | Accepted, Loving | **delete** | Now a v2 name (cue-gated). |
| `appreciated` | Accepted | **delete** | Now a synonym of Loved. |
| `gratitude` | Grateful | Grateful | |
| `compassion` | Compassionate | Caring | |
| `empathy` | Compassionate | Caring | |
| `forgive` | Forgiving | Caring | Closest match; v2 has no forgiving word. |
| `feel seen` | Understood, Heard | Understood | Kept: "seen" on its own is ignored in free text. |
| `spiritual` | Transcendent, Connected | Connected, In awe | |
| `awe` | Transcendent | **delete** | Now a synonym of In awe. |
| `let go` | Surrendering, Yielding | Free | |
| `letting go` | Surrendering, Yielding | **delete** | Now a synonym of Free. |
| `purpose` | Purposeful | Connected | |
| `stuck` | — (new) | Bored, Frustrated | Replaces the v1 name Stuck; Bored keeps it in Sacral. |
| `tired of` | — (new) | Frustrated | "Tired of this" means fed up. The longer phrase wins, so "tired" alone still means Tired. |
| `sick of` | — (new) | Frustrated | Covers "sick of school" as well as the synonym "sick of it". |

### 6.2 `needsCue` (ambiguous words that only count after a cue such as "I feel …")

| word | change | why |
|---|---|---|
| `quiet` | add | Now a name. Everyday uses: "the house is quiet". |
| `free` | add | Now a name: "free time", "for free". "Feel free to…" still slips through because "feel" is a cue. |
| `empty` | add | Now a name: "empty room", "empty stomach". |
| `torn` | add | Now a name: "torn jeans", "torn ACL". |
| `loved` | add | Now a name: "loved the movie". |
| `caring` | add | Now a name: "caring for my grandma" (an activity, not always a feeling). |
| `focused` | add | Now a name: "focused on homework" describes a task. |
| `grounded` | add | Now a name. For teens, "I got grounded" means punished. |
| `rested` | add | Now a name: "I rested my eyes". |
| `thoughtful` | add | Now a name: "a thoughtful gift". |
| `foggy` | add | Now a name: "foggy morning". |
| `disconnected` | add | Now a name: "wifi disconnected". |
| `alive` | add | Synonym of Energized: "glad to be alive", "alive and well". |
| `alone` | add | Synonym of Lonely: "home alone", "alone time". |
| `good` | add | Synonym of Happy (new): "good morning", "a good movie". |
| `settled` | add | Synonym of Grounded; replaces `settling`: "settled the bill". |
| `settling` | remove | No longer in the lexicon (covered by `settled`). |
| `still` | keep | Synonym of Grounded. |
| `present` | keep | Synonym of Mindful. |
| `open` | keep | Synonym of Free; also removed from `freeTextIgnored` so "I feel open" still matches. |
| `clear` | keep | Synonym of Clear-headed. |
| `whole` | keep | Synonym of Content. |
| `closed` | keep | Synonym of Withdrawn. |
| `heard` | keep | Synonym of Understood. |
| `listening` | keep | Synonym of Quiet. |
| `processing` | keep | Synonym of Thoughtful. |
| `searching` | keep | Name. |
| `lost` | keep | Name. |
| `fine` | keep | Synonym of Okay. |
| `okay` | keep | Name. |
| `ok` | keep | Synonym of Okay. |
| `alright` | keep | Synonym of Okay. |
| `stable` | keep | Synonym of Grounded. |
| `connected` | keep | Name. |
| `driven` | keep | Synonym of Motivated. |
| `honest` | keep | Name ("honestly", "to be honest"). |
| `understood` | keep | Name. |
| `accepted` | keep | Synonym of Loved. |
| `supported` | keep | Synonym of Safe. |
| `safe` | keep | Name. |
| `bold` | keep | Synonym of Confident. |
| `broken` | keep | Phrase → Hurt. |
| `content` | keep | Name. |

These were considered but not added, because the cost of missing real feelings is higher: `happy` ("happy birthday"), `calm` ("calm down"), `hurt` and `numb` (body sensations), and `tired` (the new `tired of` phrase handles "fed up").

### 6.3 `freeTextIgnored` (synonyms too generic to count in free text; search still uses them)

| word | change | why |
|---|---|---|
| `down` | add | Synonym of Sad, but "calm down" and "sit down" would log Sad. The phrases `feeling down` and `feel down` cover the real uses. |
| `aware` | add | Synonym of Mindful, but "I'm aware that…" isn't a feeling. |
| `real` | keep | Synonym of Honest. |
| `complete` | keep | Synonym of Content. |
| `positive` | keep | Synonym of Hopeful ("tested positive"). |
| `exploring` | keep | Synonym of Searching. |
| `sharp` | keep | Synonym of Clear-headed. |
| `blue` | keep | Synonym of Sad. |
| `flat` | keep | Synonym of Numb. |
| `cloudy` | keep | Synonym of Foggy. |
| `interested` | keep | Synonym of Curious. |
| `kind` | keep | Synonym of Caring, and part of "kind of". |
| `seen` | keep | Synonym of Understood. |

**Remove**, because these are no longer v2 synonyms. `quiet` is now a name, which the ignore list never applies to, and `open` is now cue-gated instead of ignored. The full list: `here`, `true`, `original`, `legitimate`, `plain`, `obvious`, `evident`, `transparent`, `full`, `entire`, `total`, `joined`, `linked`, `attached`, `coupled`, `united`, `integrated`, `amalgamated`, `consolidated`, `merged`, `constant`, `reliable`, `firm`, `solid`, `established`, `entrenched`, `certain`, `guaranteed`, `effective`, `direct`, `frank`, `digest`, `absorb`, `comprehend`, `integrate`, `analyze`, `landing`, `adjusting`, `resting`, `held`, `backed`, `able`, `bright`, `shining`, `brilliant`, `smooth`, `continuous`, `received`, `accessible`, `responsive`, `welcoming`, `informed`, `sensible`, `rational`, `logical`, `physical`, `moving`, `shifting`, `looking`, `hunting`, `hearing`, `observing`, `noting`, `pausing`, `lacking`, `deep`, `soft`, `mild`, `delicate`, `warm`, `cold`, `quiet`, `tight`, `restricted`, `intense`, `hungry`, `pushed`, `authorized`, `enabled`, `commanding`, `understanding`, `open`, `naked`, `obliged`, `excusing`, `allowing`, `accepting`, `flexible`, `brewing`, `innate`, `untaught`, `spontaneous`, `divine`, `vain`, `unclosed`, `unlocked`, `unfastened`, `ajar`, `unsealed`, `intent`.

### 6.4 Test expectations that change on purpose (`AniccaTests/EmotionMatcherTests.swift`)

- "so so tired" → **Tired** (was Uninspired). Intensity is still 5. No synonym is spelled "so so", so the double amplifier still works.
- "SO ANGRY!!" → **Angry** (was Frustrated). "happy but tired" → **Happy, Tired** (was Joyful, Uninspired).
- "I'm still tired" must not contain **Grounded** (was Still). "I feel open" → **Free** (was Open).
- These are unchanged: "on edge" → Anxious; search "anx" → Anxious; search "burnt out" → Overwhelmed; "can't stop crying" isn't negated (now → Sad).

## 7. Radar impact

The seven most-logged words keep their v1 centers: Tired and Happy in Sacral, Stressed in Solar Plexus, Anxious and Okay in Root, Sad and Calm in Heart. Because rule 7 pins them, they sit in four centers, not seven. Rule 8 can't be satisfied further without breaking continuity. The table lists the often-typed words whose center does change.

| Center | Gains (v1 → v2) | Losses (v1 → v2) | Net |
|---|---|---|---|
| Root | energized / energetic / alive (from Solar Plexus); imposter (from Solar Plexus) | the "calm" share v1 gave to Still | Slight gain |
| Sacral | jealous / envious (from Solar Plexus and Root); half of exhausted / drained / worn out (from Solar Plexus) | embarrassed / shame (to Solar Plexus); miss / missing / homesick (to Heart); half of feeling down / low (to Heart) | About even |
| Solar Plexus | embarrassed / shame (from Sacral) | energized (to Root), jealous (to Sacral), brave / courage (to Throat), half of exhausted (to Sacral), the hopeless share (to Crown) | Largest loss |
| Heart | feeling down / low / blue, depressed (from Crown and Sacral); miss / missing (from Sacral); not okay (adds Sad) | content (to Crown); relieved / relief (to Throat); defensive (to Throat) | Slight gain |
| Throat | relieved / relief (from Heart); brave / courage (from Solar Plexus) | — | Gain from a low base |
| Third Eye | — | — | Unchanged |
| Crown | content (from Heart); all of hopeless | the feeling down / low share (to Heart); blissful (to Sacral) | About even |

**Will a center dominate?** Heart is the likeliest to dominate, as in v1. It holds Sad and Calm plus Lonely, Grateful, Loved and now "feeling down" and "miss". Sacral is close behind. Throat, Third Eye and Crown will still read low for most users, because none of the most-logged words live there.

## 8. Open questions

- [ ] **1. Jealous: Sacral or Solar Plexus?** v1 sent "jealous / envious" to Solar Plexus (Inadequate) and Root (Insecure). *Recommendation: keep it in Sacral.* It is Sacral's only charged word, and moving it would make Solar Plexus 11 words with a 5-word charged cell, so Ashamed would have to fold back into Guilty.
- [ ] **2. Relieved in Throat?** v1 sent "relieved / relief" to Heart only because Peaceful was a catch-all, and Heart has no free slot. *Recommendation: yes.* The definition leans on "finally said / off my chest".
- [ ] **3. Insecure, Torn and Lost as negative words in Steady?** *Recommendation: yes.* They are unsettled rather than clearly high- or low-energy, and negative valence keeps the trend honest. The only alternative worth weighing is a neutral Torn.
- [ ] **4. Is Solar Plexus's charged cell too heavy?** It holds Angry, Frustrated, Stressed and Overwhelmed, 4 of 10. *Recommendation: keep it.* These are the words people actually use for pressure. If you want it lighter, the cleanest swap is to fold Overwhelmed into Stressed (v1 already routed "stressed" there) and add a calm Solar Plexus word such as Capable.
- [ ] **5. Is "Okay" an entry?** *Recommendation: yes.* It is a zone-tile example and one of the most-logged words, and v1 already routed okay / ok / fine / alright to Root.
- [ ] **6. Approve the seed changes?** Relaxed becomes a synonym of Calm and Rested takes its place; Inspired and Content swap (section 3). The fallback for the swap is Inspired back to Crown and Content back to Sacral. That leaves Sacral without a creativity word.
- [ ] **7. Accept the remaining continuity breaks?** These are energized (Solar Plexus → Root), content (Heart → Crown), relieved (Heart → Throat), brave / courage (Solar Plexus → Throat), embarrassed / shame (Sacral → Solar Plexus), defensive (Heart → Throat), feeling down / depressed (Crown and Sacral → Heart) and miss / missing (Sacral → Heart).
- [ ] **8. Ashamed or Embarrassed as the Solar Plexus entry?** Embarrassed is the plainer word for teens and is logged more often. Ashamed is deeper and matches the self-worth theme. Both rate high-arousal in the norms.
- [ ] **9. Brave in Throat (speaking up) or Solar Plexus (courage, where v1 put Bold)?** Moving it would need a Solar Plexus word out and a Throat word in.
- [ ] **10. Free: calm (as drafted, "unburdened") or bright (the norms put arousal at 5.38)?** Either keeps the zone totals in range: calm 12 / bright 16 if it moves.
- [ ] **11. "Good" as a cue-gated synonym of Happy?** v1 matched nothing for "I feel good", one of the most common things people type.
- [ ] **12. Two-target phrases.** exhausted / drained / worn out → Tired + Overwhelmed, and not okay → Sad + Overwhelmed. Both words are pre-filled on the mapping screen. Is that acceptable, or should the matcher pre-fill only the first?
- [ ] **13. Known gaps.** Sacral and Solar Plexus have no calm word, and Third Eye has no "gut feeling / intuition" word (Intuitive is dropped). Fine for v2?
- [ ] **14. Valence of kept words.** Determined and Vulnerable stay neutral, as in v1. Curious is the only kept word whose valence changes (neutral → positive, because it is now bright). Old Curious check-ins will then count as positive too, unless the lookup is changed to prefer the frozen v1 table for check-ins logged before v2. Accept that, or keep Curious neutral by moving it to Steady?

## 9. Sign-off

Approved by Isa on Nov 7, 2026. All open questions resolved as the draft recommends; where a question had no explicit recommendation (8, 9, 12, 14) the draft as written stands: Ashamed, Brave in Throat, both targets pre-filled, Curious positive.
