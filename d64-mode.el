(require 'bindat)

;; Disk info taken from http://www.unusedino.de/ec64/technical/formats/d64.html
;;  1-17        21            357           7820
;; 18-24        19            133           7170
;; 25-30        18            108           6300
;; 31-40(*)     17             85           6020

(defconst d64-disk-spec
  (let ((make-track-spec (lambda (num-sectors) 
                           `(tracks repeat ,num-sectors (struct d64-sector-spec)))))
    `((tracks-1-17 repeat 17 ,(funcall make-track-spec 21))
      (directory struct d64-directory-track-spec)
      (tracks-19-24 repeat  6 ,(funcall make-track-spec 19))
      (tracks-25-30 repeat  6 ,(funcall make-track-spec 18))
      (tracks-31-35 repeat  5 ,(funcall make-track-spec 17))))
  "Defines the layout of a standard 35-track disk image.")

(defconst d64-directory-track-spec
  '((bam struct d64-bam-sector-spec)
    (entries repeat 18 (struct d64-sector-spec)))
  "The layout for track #18 on a disk image.")

(defconst d64-bam-sector-spec
  '((first-directory-track byte)
    (first-directory-sector byte)
    (disk-dos-type byte)
    (fill 1)                   ; unused
    (bam-entries repeat 35 (struct d64-bam-entry-spec))
    (disk-name vec 16 byte)
    (fill 2)                   ; filled with $A0
    (disk-id vec 2 byte)
    (fill 1)                   ; usually $A0
    (dos-type vec 2 byte)      ; usually "2A"
    (fill 4)                   ; filled with $A0
    (fill 85))                 ; normally unused
  "The layout for the BAM sector")

(defconst d64-bam-entry-spec
  '((num-free-sectors byte)
    (free-sectors-0-7 bits 1)
    (free-sectors-8-15 bits 1)
    (free-sectors-16-23 bits 1))
  "Information about which sectors in a given track are unused.")

(defconst d64-sector-spec
  '((next-track byte)
    (next-sector byte)
    (data vec 254 byte))
  "A sector of 256 bytes.")

;; ----------------------------------------------------------------------
;; Testing: load from disk
(setq test
      (with-temp-buffer
        (set-buffer-multibyte nil)
        (insert-file-contents-literally "test.d64")
        (bindat-unpack d64-disk-spec (buffer-string))))

;; Testing extract directory entries
(bindat-get-field test 'directory 'bam 'bam-entries '0)

; (message "%s" test)



