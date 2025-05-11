;; ====== Templates ======
(deftemplate issue
   (slot type) ; e.g., management-operational / environmental / contractual
   (slot description)) ; e.g., "unclear scope", "miscommunication", etc.

(deftemplate risk-factor
   (slot stage) ; planning / execution / general-factors / specific-factors
   (slot detail))

(deftemplate contractual-defect
   (slot stage) ; general-defects / specific-defects
   (slot detail))

(deftemplate risk
   (slot id)
   (slot description))

;; ====== Planning Errors ======
(defrule detect-planning-error1
   (issue (description "lack in examination of project managers"))
   =>
   (assert (risk-factor (stage planning) (detail "lack in examination by project managers"))))

(defrule detect-planning-error2
   (issue (description "project manager misguidance"))
   =>
   (assert (risk-factor (stage planning) (detail "Misguidance by project manager"))))

;; ====== Execution Errors ======
(defrule detect-execution-error1
   (issue (description "lack in customer or consultant ability"))
   =>
   (assert (risk-factor (stage execution) (detail "Inexperienced customer or consultant"))))

(defrule detect-execution-error2
   (issue (description "lack in customer english ability"))
   =>
   (assert (risk-factor (stage execution) (detail "Communication barrier with customer"))))

;; ====== Environmental Errors ======
(defrule detect-environmental-general1
   (issue (description "complicated laws"))
   =>
   (assert (risk-factor (stage general-factors) (detail "Complicated or foreign legal environment"))))

(defrule detect-environmental-general2
   (issue (description "law or regulation change"))
   =>
   (assert (risk-factor (stage general-factors) (detail "Changing legal requirements"))))

(defrule detect-environmental-general3
   (issue (description "different business practices"))
   =>
   (assert (risk-factor (stage general-factors) (detail "Different customer business practices"))))

;; ====== Contractual Defects ======
(defrule detect-contractual-defect-general
   (issue (description "contractual defect in time for approval"))
   =>
   (assert (contractual-defect (stage general-defects) (detail "Late or missing approval clause"))))

(defrule detect-contractual-defect-specific
   =>
   (assert (contractual-defect (stage specific-defects) (detail "contractual defect in scope of equipment supply"))))

;; ====== Deduce Risk from Risk Factors ======
(defrule deduce-risk-inadequate-pm
   (risk-factor (detail "lack in examination by project managers"))
   =>
   (assert (risk (id r14) (description "Risk of unmanaged design or execution due to weak PM checks"))))

(defrule deduce-risk-misguidance
   (risk-factor (detail "Misguidance by project manager"))
   =>
   (assert (risk (id r15) (description "Risk of project execution delay or rework due to poor guidance"))))

(defrule deduce-risk-legal-complexity
   (risk-factor (detail "Complicated or foreign legal environment"))
   =>
   (assert (risk (id r13) (description "Risk of approval or compliance issues due to unfamiliar legal system"))))

(defrule deduce-risk-legal-change
   (risk-factor (detail "Changing legal requirements"))
   =>
   (assert (risk (id r16) (description "Risk of legal non-compliance due to changing laws"))))

(defrule deduce-risk-customer-practices
   (risk-factor (detail "Different customer business practices"))
   =>
   (assert (risk (id r17) (description "Risk of process mismatch between project and customer expectations"))))

(defrule deduce-risk-from-contractual-delay
   (contractual-defect (detail "Late or missing approval clause"))
   =>
   (assert (risk (id r18) (description "Risk of project delay due to missing or late approval"))))

(defrule deduce-risk-technical-guarantee
   (contractual-defect (detail "Contractual defect in scope of equipment supply"))
   =>
   (assert (risk (id r19) (description "Risk of project failure due to technical guarantees not met"))))

;; ====== Risk Alarms (Updated) ======
(defrule risk-alarm-unmanaged-design
   (risk (id r14))
   =>
   (printout t "RISK ALARM** [r14] Unmanaged design or execution due to weak PM checks" crlf))

(defrule risk-alarm-misguidance
   (risk (id r15))
   =>
   (printout t "RISK ALARM** [r15] Project execution delay or rework due to poor guidance" crlf))

(defrule risk-alarm-legal-complexity
   (risk (id r13))
   =>
   (printout t "RISK ALARM** [r13] Approval or compliance issues due to unfamiliar legal system" crlf))

(defrule risk-alarm-legal-change
   (risk (id r16))
   =>
   (printout t "RISK ALARM** [r16] Legal non-compliance due to changing laws" crlf))

(defrule risk-alarm-contractual-delay
   (risk (id r18))
   =>
   (printout t "RISK ALARM** [r18] Project delay due to missing or late approval" crlf))

(defrule risk-alarm-technical-guarantee
   (risk (id r19))
   =>
   (printout t "RISK ALARM** [r19] Project failure due to unmet technical guarantees" crlf))

;; ====== User Input Rules ======
(defrule ask-for-issue
   (declare (salience 10000))
   =>
   (printout t "Please enter an issue description (e.g., 'complicated laws', 'lack in examination of project managers'): ")
   (bind ?desc (readline))
   (assert (issue (type unknown) (description ?desc))))

;; ====== Validation Input ======
(deffunction ask-yes-no (?prompt)
   (printout t ?prompt)
   (bind ?response (read))
   (while (not (or (eq ?response yes) (eq ?response no))) do
      (printout t "Your answer should be yes or no. Please try again." crlf)
      (printout t ?prompt)
      (bind ?response (read)))
   (return ?response))

;; ====== General Rules for System Interaction ======
(deffunction show-all-risks ()
   (do-for-all-facts ((?r risk)) TRUE
      (printout t "Risk ID: " ?r:id " - " ?r:description crlf))
   (do-for-all-facts ((?f risk-factor)) TRUE
      (printout t "Risk Factor: " ?f:stage " - " ?f:detail crlf))
   (do-for-all-facts ((?d contractual-defect)) TRUE
      (printout t "Contractual Defect: " ?d:stage " - " ?d:detail crlf)))

(defrule unknown-issue-warning
   (issue (description ?desc))
   (not (or 
      (issue (description "complicated laws"))
      (issue (description "miscommunication"))
      (issue (description "control error"))
      (issue (description "lack in examination of project managers"))
      (issue (description "lack in customer or consultant ability"))
      (issue (description "lack in customer english ability"))
      (issue (description "law or regulation change"))
      (issue (description "project manager misguidance"))
      (issue (description "contractual defect in time for approval"))))
   =>
   (printout t "Warning: Issue description '" ?desc "' is not recognized by the system." crlf))