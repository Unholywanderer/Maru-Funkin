function noteHit(note) {
    if (note.noteType == 'default-gf')
        State.gf.sing(note.noteData);
}
function sustainPress(note) noteHit(note);