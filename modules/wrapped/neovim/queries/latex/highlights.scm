;; extends

;; 1. Highlight \procedure and \pseudocode macro names
(generic_command
  command: (command_name) @CryptoProc (#match? @CryptoProc "^\\\\(procedure|pseudocode)$"))

;; 2. Control keywords (\pcfor, \pcif, \pcwhile, \pcreturn, \pcdo, etc.)
(generic_command
  command: (command_name) @proc.cmd (#match? @proc.cmd "^\\\\pc(for|endfor|if|endif|fi|then|else|do|to|return|while|endwhile)$"))

;; 3. Assignment operators (\sample, \leftarrow, \gets) inside curly_group blocks
(curly_group
  (generic_command command: (command_name) @assignment (#match? @assignment "^\\\\(sample|leftarrow|gets)$")))

(curly_group
  (text
    (generic_command command: (command_name) @assignment (#match? @assignment "^\\\\(sample|leftarrow|gets)$"))))
