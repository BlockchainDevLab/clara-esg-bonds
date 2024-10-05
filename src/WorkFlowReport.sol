// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WorkflowReport {
    struct Project {
        uint256 projectId;
        string projectName;
        uint256 bondId;
        uint256 allocation;
        uint256 lastReportDate;
        uint256 nextReportDueDate;
        bool reportSubmitted;
    }

    struct ProjectReport {
        uint256 reportId;
        uint256 projectId;
        string reportDataHash; // IPFS/Filecoin hash of report
        bool validated;
        bool penaltyApplied;
        uint256 penaltyAmount;
        address auditor;
        string comments;
    }

    event ProjectAdded(uint256 projectId, string projectName, uint256 bondId);
    event ReportSubmitted(uint256 reportId, uint256 projectId, bool validated);
    event PenaltyApplied(uint256 projectId, uint256 penaltyAmount);
    event ReportAudited(uint256 reportId, address auditor, bool validated, string comments);

    uint256 public projectCounter;
    uint256 public reportCounter;

    mapping(uint256 => Project) public projects;
    mapping(uint256 => ProjectReport) public projectReports;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyAuditor() {
        require(auditors[msg.sender], "Not authorized as auditor");
        _;
    }

    modifier projectExists(uint256 projectId) {
        require(projects[projectId].projectId != 0, "Project does not exist");
        _;
    }

    modifier reportExists(uint256 reportId) {
        require(projectReports[reportId].reportId != 0, "Report does not exist");
        _;
    }

    mapping(address => bool) public auditors;

    function addAuditor(address auditor) public onlyOwner {
        auditors[auditor] = true;
    }

    function removeAuditor(address auditor) public onlyOwner {
        auditors[auditor] = false;
    }

    function addProjectToBond(uint256 bondId, string memory projectName, uint256 allocation, uint256 reportInterval)
        public
        onlyOwner
    {
        projectCounter++;
        uint256 nextReportDueDate = block.timestamp + reportInterval;
        projects[projectCounter] = Project(projectCounter, projectName, bondId, allocation, 0, nextReportDueDate, false);
        emit ProjectAdded(projectCounter, projectName, bondId);
    }

    function submitReport(uint256 projectId, string memory reportDataHash) public projectExists(projectId) {
        Project storage project = projects[projectId];
        require(block.timestamp >= project.nextReportDueDate, "Report not yet due");

        reportCounter++;
        projectReports[reportCounter] =
            ProjectReport(reportCounter, projectId, reportDataHash, false, false, 0, address(0), "");
        project.lastReportDate = block.timestamp;
        project.reportSubmitted = true;
        project.nextReportDueDate = block.timestamp + 30 days;

        emit ReportSubmitted(reportCounter, projectId, false);
    }

    function auditReport(uint256 reportId, bool validated, string memory comments)
        public
        onlyAuditor
        reportExists(reportId)
    {
        ProjectReport storage report = projectReports[reportId];
        require(!report.validated, "Report already validated");

        report.validated = validated;
        report.auditor = msg.sender;
        report.comments = comments;

        if (!validated) {
            applyPenalty(report.projectId, 100); // Example penalty
        }

        emit ReportAudited(reportId, msg.sender, validated, comments);
    }

    function applyPenalty(uint256 projectId, uint256 penaltyAmount) internal {
        ProjectReport storage report = projectReports[reportCounter];
        report.penaltyApplied = true;
        report.penaltyAmount = penaltyAmount;

        emit PenaltyApplied(projectId, penaltyAmount);
    }

    function getProject(uint256 projectId)
        public
        view
        returns (string memory projectName, uint256 allocation, bool reportSubmitted)
    {
        Project storage project = projects[projectId];
        return (project.projectName, project.allocation, project.reportSubmitted);
    }

    function getReport(uint256 reportId)
        public
        view
        returns (uint256 projectId, bool validated, string memory comments, address auditor)
    {
        ProjectReport storage report = projectReports[reportId];
        return (report.projectId, report.validated, report.comments, report.auditor);
    }
}
