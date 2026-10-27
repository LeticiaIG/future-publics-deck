# future publics deck

a thing-from-the-future hackpack for deliberating urban futures.
digital version based on *The Thing from the Future* (Stuart Candy & Jeff Watson, Situation Lab, 2014),
with two new suits, **move** and **public**, and a "no tech" rule. interface and decks in spanish and english.

six cards (arc · terrain · object · move · mood · public), lock the ones you want to keep, deal variations,
invent a "thing from the future" with a six-step storyboard, a question for deliberation, a blender brief,
a drawing prompt, and a drawing (uploaded or generated).

part of **Future Publics: Multimodal AI for Human Experience across Time, Space, Culture, and Machines**.

## how it works
- everything is one `index.html`: no build step, no tracking. your own ideas and decks live in your browser.
- **ai**: paste your own api key (claude or openai) in the page, or copy the prompt with ⎘, use any chat, and paste the json answer back.
- **images**: upload a drawing or photo of a sketch; with an openai key you can also generate one from the scene prompt.
- **shared gallery** (optional): a free Supabase project. run `supabase.sql` in its SQL editor, then put the
  project url and anon public key in `SHARED` at the top of the script in `index.html`. people can then publish
  their inventions with a name and a place (city detected from the connection, always editable; no ip is stored),
  browse everyone's, filter by terrain and place, see their own and delete their own (the browser that published
  an entry holds a secret owner token; the database only deletes rows that match it). to hide any entry set `hidden = true` in Supabase.

## run locally
open `index.html` in a browser.

## license
cc by-sa 4.0 for the deck contents · mit for the code
