output "detector_id" {
  description = "ID of the GuardDuty detector in this region."
  value       = aws_guardduty_detector.this.id
}
