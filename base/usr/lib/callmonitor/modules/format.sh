f_duration() {
    local d=$1
    printf "%d:%02d:%02d\n" $((d/3600)) $((d/60%60)) $((d%60))
}
